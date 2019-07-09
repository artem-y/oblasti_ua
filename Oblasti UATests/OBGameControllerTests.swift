//
//  OBGameControllerTests.swift
//  Oblasti UATests
//
//  Created by EasyRider on 7/8/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import XCTest
@testable import Oblasti_UA

class OBGameControllerTests: XCTestCase {
    // MARK: Nested Types
    struct FailMessage {
        static let gameControllerHasNoCurrentRegion = "Game controller has no current region."
    }
    
    // MARK: - Unit Under Test & Necessary Values
    var gameController: OBGameController!
    var regionsOfUkraine: [OBRegion]! // Regions supposed to be in Ukraine.json file
    
    var delegate: TestGameControllerDelegate!

    // MARK: - Test Case Lifecycle Methods
    override func setUp() {
        gameController = OBGameController(game: nil)
        delegate = TestGameControllerDelegate()
        gameController.delegate = delegate
        
        regionsOfUkraine = OBResources.shared.loadRegions(fromFileNamed: OBResources.FileName.ukraine)
        
        
    }

    override func tearDown() {
        gameController = nil
        regionsOfUkraine = nil
        delegate = nil
        UserDefaults.standard.removeObject(forKey: OBResources.UserDefaultsKey.lastUnfinishedGame)
    }
    
    // MARK: - Initialization Tests
    func test_Init_WithNilAndHasSavedGameWithRegionsInFile_GameEqualsSavedGame() {
        // 1. Arrange
        let nonDefaultGame = OBGame(mode: OBGame.Mode.pointer, regions: regionsOfUkraine, regionsLeft: regionsOfUkraine)
        gameController = OBGameController(game: nonDefaultGame)
        
        // 2. Act
        gameController.saveGame()
        let newGameController = OBGameController(game: nil)

        // 3. Assert
        XCTAssertEqual(newGameController.gameResult, nonDefaultGame)

    }
    
    func test_Init_WithNilAndHasSavedGameWithRegionsNotInFile_GameEqualsDefaultGameForCurrentMode() {
        // 1. Arrange
        let regions = [OBRegion(name: "NonExistentRegion", path: UIBezierPath())]
        let nonDefaultGame = OBGame(mode: OBGame.Mode.pointer, regions: regions, regionsLeft: regions)
        gameController = OBGameController(game: nonDefaultGame)
        
        // 2. Act
        gameController.saveGame()
        let newGameController = OBGameController(game: nil)
        
        // 3. Assert
        XCTAssertEqual(newGameController.gameResult, OBGame.defaultForCurrentMode)
        
    }
    
    // MARK: - Current Region Tests
    func test_CurrentRegion_AfterInitInPointerMode_EqualsNil() {
        // 1. Arrange
        let gameInPointerMode = OBGame(mode: .pointer, regions: OBGame.default.regions, regionsLeft: OBGame.default.regionsLeft)
        
        // 2. Act
        gameController = OBGameController(game: gameInPointerMode)
        
        // 3. Assert
        XCTAssertNil(gameController.currentRegion)
    }

    // MARK: - Regions Left Tests
    func test_CheckSelection_WithCorrectNameInClassicMode_RemovesCheckedRegion() {
        // 1. Arrange
        gameController = OBGameController(game: OBGame(mode: .classic, regions: regionsOfUkraine, regionsLeft: regionsOfUkraine))
        
        // 2. Act
        guard let currentRegion = gameController.currentRegion else { XCTFail(FailMessage.gameControllerHasNoCurrentRegion); return }
        gameController.checkSelection(named: currentRegion.name)
        
        
        // 3. Assert
        XCTAssertFalse(gameController.gameResult.regionsLeft.contains(currentRegion))
    }
    
    func test_CheckSelection_WithWrongNameInNorepeatMode_DoesNotRemoveCheckedRegion() {
        // 1. Arrange
        gameController = OBGameController(game: OBGame(mode: .classic, regions: regionsOfUkraine, regionsLeft: regionsOfUkraine))
        let wrongRegion: OBRegion = (gameController.currentRegion == regionsOfUkraine[0]) ? regionsOfUkraine[1] : regionsOfUkraine[0]
        
        // 2. Act
        guard let currentRegion = gameController.currentRegion else { XCTFail(FailMessage.gameControllerHasNoCurrentRegion); return }
        gameController.checkSelection(named: wrongRegion.name)
        
        
        // 3. Assert
        XCTAssertTrue(gameController.gameResult.regionsLeft.contains(currentRegion))
    }
    
    func test_CheckSelection_WithCorrectNameInNorepeatMode_RemovesCheckedRegion() {
        // 1. Arrange
        gameController = OBGameController(game: OBGame(mode: .norepeat, regions: regionsOfUkraine, regionsLeft: regionsOfUkraine))
        
        // 2. Act
        guard let currentRegion = gameController.currentRegion else { XCTFail(FailMessage.gameControllerHasNoCurrentRegion); return }
        gameController.checkSelection(named: currentRegion.name)
        
        
        // 3. Assert
        XCTAssertFalse(gameController.gameResult.regionsLeft.contains(currentRegion))
    }
    
    func test_CheckSelection_WithWrongNameInNorepeatMode_RemovesCheckedRegion() {
        // 1. Arrange
        gameController = OBGameController(game: OBGame(mode: .norepeat, regions: regionsOfUkraine, regionsLeft: regionsOfUkraine))
        let wrongRegion: OBRegion = (gameController.currentRegion == regionsOfUkraine[0]) ? regionsOfUkraine[1] : regionsOfUkraine[0]
        
        // 2. Act
        guard let currentRegion = gameController.currentRegion else { XCTFail(FailMessage.gameControllerHasNoCurrentRegion); return }
        gameController.checkSelection(named: wrongRegion.name)
        
        
        // 3. Assert
        XCTAssertFalse(gameController.gameResult.regionsLeft.contains(currentRegion))
    }
    
    // MARK: - Mistakes Count Tests
    func test_CheckSelection_WithWrongNameInClassicMode_MistakesCountIncrementsByOne() {
        // 1. Arrange
        gameController = OBGameController(game: OBGame(mode: .classic, regions: regionsOfUkraine, regionsLeft: regionsOfUkraine))
        let initialMistakesCount = gameController.gameResult.mistakesCount
        let wrongRegion = (gameController.currentRegion == regionsOfUkraine[0]) ? regionsOfUkraine[1] : regionsOfUkraine[0]
        
        // 2. Act
        gameController.checkSelection(named: wrongRegion.name)
        
        // 3. Assert
        XCTAssertEqual(gameController.gameResult.mistakesCount, initialMistakesCount + 1)
    }
    
    func test_CheckSelection_WithCorrectNameInClassicMode_MistakesCountDoesNotChange() {
        // 1. Arrange
        gameController = OBGameController(game: OBGame(mode: .classic, regions: regionsOfUkraine, regionsLeft: regionsOfUkraine))
        let initialMistakesCount = gameController.gameResult.mistakesCount
        
        // 2. Act
        guard let currentRegion = gameController.currentRegion else { XCTFail(FailMessage.gameControllerHasNoCurrentRegion); return }
        gameController.checkSelection(named: currentRegion.name)
        
        // 3. Assert
        XCTAssertEqual(gameController.gameResult.mistakesCount, initialMistakesCount)
    }
    
    func test_CheckSelection_WithWrongNameInNorepeatMode_MistakesCountIncrementsByOne() {
        // 1. Arrange
        gameController = OBGameController(game: OBGame(mode: .norepeat, regions: regionsOfUkraine, regionsLeft: regionsOfUkraine))
        let initialMistakesCount = gameController.gameResult.mistakesCount
        let wrongRegion = (gameController.currentRegion == regionsOfUkraine[0]) ? regionsOfUkraine[1] : regionsOfUkraine[0]
        
        // 2. Act
        gameController.checkSelection(named: wrongRegion.name)
        
        // 3. Assert
        XCTAssertEqual(gameController.gameResult.mistakesCount, initialMistakesCount + 1)
    }
    
    func test_CheckSelection_WithCorrectNameInNorepeatMode_MistakesCountDoesNotChange() {
        // 1. Arrange
        gameController = OBGameController(game: OBGame(mode: .norepeat, regions: regionsOfUkraine, regionsLeft: regionsOfUkraine))
        let initialMistakesCount = gameController.gameResult.mistakesCount
        
        // 2. Act
        guard let currentRegion = gameController.currentRegion else { XCTFail(FailMessage.gameControllerHasNoCurrentRegion); return }
        gameController.checkSelection(named: currentRegion.name)
        
        // 3. Assert
        XCTAssertEqual(gameController.gameResult.mistakesCount, initialMistakesCount)
    }
    
    // MARK: - Delegate Tests
    func test_Delegate_OnCheckingCorrectName_ReactsToCorrectChoice() {
        // 1. Act
        if let currentRegionName = gameController.currentRegion?.name {
            gameController.checkSelection(named: currentRegionName)
        }
        
        // 2. Assert
        XCTAssert(delegate.didReactToCorrectChoice)
    }
    
    func test_Delegate_OnCheckingWrongName_ReactsToWrongChoice() {
        // 1. Arrange
        let wrongRegionName = (gameController.currentRegion == regionsOfUkraine.first) ? regionsOfUkraine[1].name : regionsOfUkraine[0].name
        
        // 2. Act
        gameController.checkSelection(named: wrongRegionName)
        
        // 3. Assert
        XCTAssert(delegate.didReactToWrongChoice)
    }
    
    func test_Delegate_WhenShowsTimeSettingIsTrue_ReactsToTimerValueChangeWithinOneSecond() {
        // 1. Arrange
        OBSettingsController.shared.settings.showsTime = true
        
        // 2. Assert
        wait(for: [delegate.reactToTimerValueChangedExpectation], timeout: 1.0)
        
    }
    
    func test_Delegate_WhenShowsTimeSettingIsFalse_DoesNotReactToTimerValueChange() {
        // 1. Arrange
        OBSettingsController.shared.settings.showsTime = false
        let doNotReactToTimerValueChangedExpectation = delegate.reactToTimerValueChangedExpectation
        doNotReactToTimerValueChangedExpectation.isInverted = true
        
        // 2. Assert
        wait(for: [doNotReactToTimerValueChangedExpectation], timeout: 2.0)
    }
    
    func test_Delegate_OnCheckingLastCorrectNameInNorepeatMode_ReactsToEndOfGame() {
        // 1. Arrange
        let lastRegionLeft = regionsOfUkraine[0]
        let gameWithOneRegionLeft = OBGame(mode: .norepeat, regions: regionsOfUkraine, regionsLeft: [lastRegionLeft])
        gameController = OBGameController(game: gameWithOneRegionLeft)
        gameController.delegate = delegate
        
        // 2. Act
        gameController.checkSelection(named: lastRegionLeft.name)
        
        // 3. Assert
        XCTAssertTrue(delegate.didReactToEndOfGame)
        
    }
    
    func test_Delegate_OnCheckingLastWrongNameInNorepeatMode_ReactsToEndOfGame() {
        // 1. Arrange
        let lastRegionLeft = regionsOfUkraine[0]
        let wrongRegion = regionsOfUkraine[1]
        let gameWithOneRegionLeft = OBGame(mode: .norepeat, regions: regionsOfUkraine, regionsLeft: [lastRegionLeft])
        gameController = OBGameController(game: gameWithOneRegionLeft)
        gameController.delegate = delegate
        
        // 2. Act
        gameController.checkSelection(named: wrongRegion.name)
        
        // 3. Assert
        XCTAssertTrue(delegate.didReactToEndOfGame)
        
    }
    
    func test_Delegate_OnCheckingLastCorrectNameInClassicMode_ReactsToEndOfGame() {
        // 1. Arrange
        let lastRegionLeft = regionsOfUkraine[0]
        let gameWithOneRegionLeft = OBGame(mode: .classic, regions: regionsOfUkraine, regionsLeft: [lastRegionLeft])
        gameController = OBGameController(game: gameWithOneRegionLeft)
        gameController.delegate = delegate
        
        // 2. Act
        gameController.checkSelection(named: lastRegionLeft.name)
        
        // 3. Assert
        XCTAssertTrue(delegate.didReactToEndOfGame)
        
    }
    
    func test_Delegate_OnCheckingLastWrongNameInClassicMode_DoesNotReactToEndOfGame() {
        // 1. Arrange
        let lastRegionLeft = regionsOfUkraine[0]
        let wrongRegion = regionsOfUkraine[1]
        let gameWithOneRegionLeft = OBGame(mode: .classic, regions: regionsOfUkraine, regionsLeft: [lastRegionLeft])
        gameController = OBGameController(game: gameWithOneRegionLeft)
        gameController.delegate = delegate
        
        // 2. Act
        gameController.checkSelection(named: wrongRegion.name)
        
        // 3. Assert
        XCTAssertFalse(delegate.didReactToEndOfGame)
        
    }
    
}

#if DEBUG
// MARK: - Game Controller Delegate
class TestGameControllerDelegate: OBGameControllerDelegate {
    // Values to check
    var didReactToCorrectChoice = false
    var didReactToWrongChoice = false
    var didReactToEndOfGame = false
    
    let reactToTimerValueChangedExpectation = XCTestExpectation(description: "Game controller delegate expected to react to timer value change")

    
    // MARK: -
    // OBGameControllerDelegate Protocol Methods
    func reactToCorrectChoice() {
        didReactToCorrectChoice = true
    }
    
    func reactToWrongChoice() {
        didReactToWrongChoice = true
    }
    
    func reactToTimerValueChange() {
        reactToTimerValueChangedExpectation.fulfill()
    }
    
    func reactToEndOfGame() {
        didReactToEndOfGame = true
    }
    
}
#endif
