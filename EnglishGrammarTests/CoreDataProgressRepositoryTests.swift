import CoreData
import Foundation
import XCTest
@testable import EnglishGrammar

@MainActor
final class CoreDataProgressRepositoryTests: XCTestCase {
    func testInMemoryStoreStartsEmpty() {
        let repository = CoreDataProgressRepository(inMemory: true)

        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
        XCTAssertEqual(repository.bestScore(for: "present-simple"), 0)
    }

    func testInMemoryStoresAreIndependent() throws {
        let firstRepository = CoreDataProgressRepository(inMemory: true)
        try firstRepository.saveResult(lessonID: "present-simple", correctAnswers: 9, totalQuestions: 10)

        let secondRepository = CoreDataProgressRepository(inMemory: true)
        XCTAssertEqual(secondRepository.bestScore(for: "present-simple"), 0)
        XCTAssertTrue(secondRepository.completedLessonIDs().isEmpty)

        try secondRepository.saveResult(lessonID: "present-simple", correctAnswers: 2, totalQuestions: 10)

        XCTAssertEqual(firstRepository.bestScore(for: "present-simple"), 9)
        XCTAssertEqual(firstRepository.completedLessonIDs(), Set(["present-simple"]))
        XCTAssertEqual(secondRepository.bestScore(for: "present-simple"), 2)
        XCTAssertTrue(secondRepository.completedLessonIDs().isEmpty)
    }

    func testSavedResultCanBeRead() throws {
        let repository = CoreDataProgressRepository(inMemory: true)

        try repository.saveResult(lessonID: "zero", correctAnswers: 4, totalQuestions: 10)

        XCTAssertEqual(repository.bestScore(for: "zero"), 4)
        XCTAssertEqual(repository.bestScore(for: "first"), 0)
        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
    }

    func testPassThresholdRequiresAtLeastSevenOutOfTen() throws {
        let repository = CoreDataProgressRepository(inMemory: true)

        try repository.saveResult(lessonID: "present-simple", correctAnswers: 6, totalQuestions: 10)

        XCTAssertEqual(repository.bestScore(for: "present-simple"), 6)
        XCTAssertFalse(repository.completedLessonIDs().contains("present-simple"))

        try repository.saveResult(lessonID: "present-simple", correctAnswers: 7, totalQuestions: 10)

        XCTAssertEqual(repository.bestScore(for: "present-simple"), 7)
        XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple"]))
    }

    func testWorseAttemptPreservesBestScoreAndCompletion() throws {
        let repository = CoreDataProgressRepository(inMemory: true)

        try repository.saveResult(lessonID: "cm-simple", correctAnswers: 8, totalQuestions: 10)
        try repository.saveResult(lessonID: "cm-simple", correctAnswers: 3, totalQuestions: 10)

        XCTAssertEqual(repository.bestScore(for: "cm-simple"), 8)
        XCTAssertEqual(repository.completedLessonIDs(), Set(["cm-simple"]))

        try repository.saveResult(lessonID: "cm-simple", correctAnswers: 10, totalQuestions: 10)

        XCTAssertEqual(repository.bestScore(for: "cm-simple"), 10)
        XCTAssertEqual(repository.completedLessonIDs(), Set(["cm-simple"]))
    }

    func testSavingResultsKeepsSectionsIndependent() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        try repository.saveResult(lessonID: "s-be", correctAnswers: 3, totalQuestions: 10)
        try repository.saveResult(lessonID: "zero", correctAnswers: 6, totalQuestions: 10)
        try repository.saveResult(lessonID: "cm-simple", correctAnswers: 4, totalQuestions: 10)

        try repository.saveResult(lessonID: "present-simple", correctAnswers: 8, totalQuestions: 10)

        XCTAssertEqual(repository.bestScore(for: "s-be"), 3)
        XCTAssertEqual(repository.bestScore(for: "zero"), 6)
        XCTAssertEqual(repository.bestScore(for: "cm-simple"), 4)
        XCTAssertEqual(repository.bestScore(for: "present-simple"), 8)
        XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple"]))

        try repository.saveResult(lessonID: "zero", correctAnswers: 7, totalQuestions: 10)

        XCTAssertEqual(repository.bestScore(for: "s-be"), 3)
        XCTAssertEqual(repository.bestScore(for: "cm-simple"), 4)
        XCTAssertEqual(repository.bestScore(for: "present-simple"), 8)
        XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple", "zero"]))
    }

    func testPassingLessonUnlocksNextLessonOnlyInItsSection() async throws {
        let sections = try await BundledGrammarRepository().loadSections()
        XCTAssertEqual(sections.count, 4)

        for target in sections {
            let repository = CoreDataProgressRepository(inMemory: true)
            let firstLesson = try XCTUnwrap(target.lessons.first)
            try repository.saveResult(lessonID: firstLesson.id, correctAnswers: 6, totalQuestions: 10)
            XCTAssertFalse(
                LessonUnlockRule.isUnlocked(
                    at: 1, lessons: target.lessons, completedIDs: repository.completedLessonIDs()
                ),
                "A failing result must not unlock the next lesson in \(target.id)"
            )

            try repository.saveResult(lessonID: firstLesson.id, correctAnswers: 7, totalQuestions: 10)

            for section in sections {
                XCTAssertEqual(
                    LessonUnlockRule.isUnlocked(
                        at: 1, lessons: section.lessons, completedIDs: repository.completedLessonIDs()
                    ),
                    section.id == target.id,
                    "Completing \(target.id)/\(firstLesson.id) must only unlock its own next lesson, not \(section.id)"
                )
            }
        }
    }

    func testSavedResultsAreRestoredWhenReopeningTemporaryStore() throws {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: directory) }
        let storeURL = directory.appendingPathComponent("Progress.sqlite")

        try autoreleasepool {
            let repository = CoreDataProgressRepository(storeURL: storeURL)
            try repository.saveResult(lessonID: "present-simple", correctAnswers: 8, totalQuestions: 10)
            try repository.saveResult(lessonID: "present-simple", correctAnswers: 4, totalQuestions: 10)
            try repository.saveResult(lessonID: "zero", correctAnswers: 6, totalQuestions: 10)
        }

        XCTAssertTrue(fileManager.fileExists(atPath: storeURL.path))

        try autoreleasepool {
            let repository = CoreDataProgressRepository(storeURL: storeURL)

            XCTAssertEqual(repository.bestScore(for: "present-simple"), 8)
            XCTAssertEqual(repository.bestScore(for: "zero"), 6)
            XCTAssertEqual(repository.bestScore(for: "cm-simple"), 0)
            XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple"]))

            try repository.saveResult(lessonID: "zero", correctAnswers: 7, totalQuestions: 10)

            XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple", "zero"]))
        }
    }

    func testLegacySQLiteProgressSurvivesChangedQuestionCountsAndReopening() throws {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: directory) }
        let storeURL = directory.appendingPathComponent("LegacyProgress.sqlite")

        try autoreleasepool {
            try writeLegacyProgressFixture(at: storeURL)
        }
        let legacyMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL,
            options: nil
        )
        let legacyVersionHashes = try XCTUnwrap(legacyMetadata[NSStoreModelVersionHashesKey] as? [String: Data])

        try autoreleasepool {
            let repository = CoreDataProgressRepository(storeURL: storeURL)

            XCTAssertEqual(repository.bestScore(for: "present-simple"), 7)
            XCTAssertEqual(repository.bestScore(for: "zero"), 6)
            XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple"]))

            try repository.saveResult(lessonID: "present-simple", correctAnswers: 6, totalQuestions: 20)
            try repository.saveResult(lessonID: "zero", correctAnswers: 1, totalQuestions: 5)

            XCTAssertEqual(repository.bestScore(for: "present-simple"), 7)
            XCTAssertEqual(repository.bestScore(for: "zero"), 6)
            XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple"]))
        }

        autoreleasepool {
            let repository = CoreDataProgressRepository(storeURL: storeURL)

            XCTAssertEqual(repository.bestScore(for: "present-simple"), 7)
            XCTAssertEqual(repository.bestScore(for: "zero"), 6)
            XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple"]))
        }

        let reopenedMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL,
            options: nil
        )
        let reopenedVersionHashes = try XCTUnwrap(reopenedMetadata[NSStoreModelVersionHashesKey] as? [String: Data])
        XCTAssertEqual(reopenedVersionHashes, legacyVersionHashes)
    }

    private func writeLegacyProgressFixture(at storeURL: URL) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: makeLegacyProgressModel())
        let store = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: [
                NSMigratePersistentStoresAutomaticallyOption: false,
                NSInferMappingModelAutomaticallyOption: false
            ]
        )
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        for (lessonID, bestScore, isCompleted) in [("present-simple", 7, true), ("zero", 6, false)] {
            let record = NSEntityDescription.insertNewObject(forEntityName: "LessonProgress", into: context)
            record.setValue(lessonID, forKey: "lessonID")
            record.setValue(bestScore, forKey: "bestScore")
            record.setValue(isCompleted, forKey: "isCompleted")
            record.setValue(Date(timeIntervalSince1970: 1_700_000_000), forKey: "updatedAt")
        }
        try context.save()
        context.reset()
        try coordinator.remove(store)
    }

    private func makeLegacyProgressModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "LessonProgress"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

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

        entity.properties = [identifier, score, completed, updated]
        entity.uniquenessConstraints = [["lessonID"]]
        model.entities = [entity]
        return model
    }
}
