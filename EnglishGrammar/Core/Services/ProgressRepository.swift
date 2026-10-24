//
//  ProgressRepository.swift
//  EnglishGrammar
//
//  Maintainer: Alexander Shevtsov
//  Copyright © 2026 Alexander Shevtsov.
//

import CoreData
import Foundation

@MainActor
protocol LessonCompletionReading: AnyObject {
    func completedLessonIDs() -> Set<String>
}

@MainActor
protocol QuizResultSaving: AnyObject {
    func saveResult(lessonID: String, correctAnswers: Int, totalQuestions: Int) throws
}

@MainActor
protocol ProgressRepository: LessonCompletionReading, QuizResultSaving {
    func bestScore(for id: String) -> Int
}

@MainActor
final class CoreDataProgressRepository: ProgressRepository {
    private let container: NSPersistentContainer

    init(inMemory: Bool = false, storeURL: URL? = nil) {
        let schema = NSManagedObjectModel()
        let progressEntity = NSEntityDescription()
        progressEntity.name = "LessonProgress"
        progressEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let identifier = NSAttributeDescription()
        identifier.name = "lessonID"
        identifier.attributeType = .stringAttributeType
        identifier.isOptional = false

        let score = NSAttributeDescription()
        score.name = "bestScore"
        score.attributeType = .integer32AttributeType
        score.isOptional = false
        score.defaultValue = 0

        let completed = NSAttributeDescription()
        completed.name = "isCompleted"
        completed.attributeType = .booleanAttributeType
        completed.isOptional = false
        completed.defaultValue = false

        let updated = NSAttributeDescription()
        updated.name = "updatedAt"
        updated.attributeType = .dateAttributeType
        updated.isOptional = false

        progressEntity.properties = [identifier, score, completed, updated]
        progressEntity.uniquenessConstraints = [["lessonID"]]
        schema.entities = [progressEntity]

        container = NSPersistentContainer(name: "EnglishGrammar", managedObjectModel: schema)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else if let storeURL {
            container.persistentStoreDescriptions.first?.url = storeURL
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Unable to load progress store: \(error)")
            }
        }
    }

    func completedLessonIDs() -> Set<String> {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LessonProgress")
        request.predicate = NSPredicate(format: "isCompleted == YES")
        let records = (try? container.viewContext.fetch(request)) ?? []
        return Set(records.compactMap { $0.value(forKey: "lessonID") as? String })
    }

    func bestScore(for id: String) -> Int {
        guard let record = findProgress(for: id) else { return 0 }
        return record.value(forKey: "bestScore") as? Int ?? 0
    }

    func saveResult(lessonID: String, correctAnswers: Int, totalQuestions: Int) throws {
        guard totalQuestions > 0,
              correctAnswers >= 0,
              correctAnswers <= totalQuestions,
              correctAnswers <= Int(Int32.max) else { return }
        let context = container.viewContext
        let record = findProgress(for: lessonID) ?? NSEntityDescription.insertNewObject(forEntityName: "LessonProgress", into: context)
        let currentScore = record.value(forKey: "bestScore") as? Int ?? 0
        let wasCompleted = record.value(forKey: "isCompleted") as? Bool ?? false
        let passedAttempt = QuizPassingRule.isPassing(
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions
        )
        record.setValue(lessonID, forKey: "lessonID")
        record.setValue(max(currentScore, correctAnswers), forKey: "bestScore")
        record.setValue(wasCompleted || passedAttempt, forKey: "isCompleted")
        record.setValue(Date(), forKey: "updatedAt")
        try context.save()
    }

    private func findProgress(for id: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LessonProgress")
        request.predicate = NSPredicate(format: "lessonID == %@", id)
        request.fetchLimit = 1
        return try? container.viewContext.fetch(request).first
    }
}
