import XCTest
@testable import SwiftAsyncMutex
import Combine

final class AsyncSwiftMutexTests: XCTestCase {

  @available(macOS 10.15, iOS 15.0, *)
  func test_MutexTaskManager() async {
    let startDate = Date.now
    let mutex = AsyncMutexManager(mutexCount: 1)
    let testExpectation: XCTestExpectation = .init()

    let innerTaskAction: (_ index: Int) async -> Void = { ind in
      print("\(#function) \(ind) task will run")
      await mutex.willTask()
      sleep(5)
      await mutex.didTask()
      print("\(#function) \(ind) task did run")
    }

    await withTaskGroup(of: Void.self) { group in
      for i in 1...3 {
        group.addTask { await innerTaskAction(i) }
      }

      group.addTask {
        print("\(#function) wait task finished")
        await mutex.isFinish()
        print("\(#function) finished all task")
        testExpectation.fulfill()

      }
    }
    let endDate = Date.now
    await fulfillment(of: [testExpectation])
    XCTAssertTrue(Int(endDate.timeIntervalSince(startDate).rounded()) == 15)
  }

  @available(macOS 10.15, iOS 15.0, *)
  func test_MultipleOfIsFinish() async {
    let mutex = AsyncMutexManager(mutexCount: 1)
    let firstTestExpectation: XCTestExpectation = .init()
    let secondTestExpectation: XCTestExpectation = .init()

    let innerTaskAction: (_ index: Int) async -> Void = { ind in
      print("\(#function) \(ind) task will run")
      await mutex.willTask()
      sleep(5)
      await mutex.didTask()
      print("\(#function) \(ind) task did run")
    }

    await withTaskGroup(of: Void.self) { group in
      // InitialTask
      let initialTaskCount = 3
      for ind in (1...initialTaskCount) {
        group.addTask { await innerTaskAction(ind) }
      }
      group.addTask {
        print( "\(#function) wait task finished")
        await mutex.isFinish()
        print("\(#function) finished all task")
        firstTestExpectation.fulfill()
      }

      // FinalTask
      group.addTask {
        sleep(16) // wait prev task
        print("\(#function) 4 Task Will ")
        await mutex.willTask()
        sleep(5)
        await mutex.didTask()
        print("\(#function) 4 Task finished")
      }

      group.addTask {
        sleep(16) // wait prev task
        print("\(#function) wait task finished")
        await mutex.isFinish()
        print("\(#function) finished all task")
        secondTestExpectation.fulfill()
      }
    }

    await fulfillment(of: [firstTestExpectation, secondTestExpectation])
  }

  @available(macOS 10.15, iOS 15.0, *)
  func test_MultipleOfMutex() async {
    let startDate = Date.now
    let mutex = AsyncMutexManager(mutexCount: 3)
    let testExpectation: XCTestExpectation = .init()

    let innerTaskAction: (_ index: Int) async -> Void = { ind in
      print("\(#function) \(ind) task will run")
      await mutex.willTask()
      sleep(5)
      await mutex.didTask()
      print("\(#function) \(ind) task did run")
    }

    await withTaskGroup(of: Void.self) { group in
      for i in 1...3 {
        group.addTask { await innerTaskAction(i) }
      }

      group.addTask {
        print("\(#function) wait task finished")
        await mutex.isFinish()
        print("\(#function) finished all task")
        testExpectation.fulfill()
      }
    }
    let endDate = Date.now
    await fulfillment(of: [testExpectation])
    XCTAssertTrue(Int(endDate.timeIntervalSince(startDate).rounded()) == 5)
  }
}
