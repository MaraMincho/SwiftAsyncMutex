//
//  Test.swift
//  SwifAsynctMutex
//
//  Created by MaraMincho on 10/14/24.
//

import Testing
@testable import SwiftAsyncMutex
import Combine
import Foundation



struct SwiftAsyncMutexTests {

  @available(macOS 10.15, iOS 15.0, *)
  @Test func mutexTaskManager() async throws {
    let startDate = Date.now
    let mutex = AsyncMutexManager(mutexCount: 1)

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
        await mutex.waitForFinish()
        print("\(#function) finished all task")

      }
    }
    let endDate = Date.now
    #expect(Int(endDate.timeIntervalSince(startDate).rounded()) == 15)
  }

  @available(macOS 10.15, iOS 15.0, *)
  @Test func multipleOfWaitForFinish() async {
    let mutex = AsyncMutexManager(mutexCount: 1)

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
        await mutex.waitForFinish()
        print("\(#function) finished all task")
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
        await mutex.waitForFinish()
        print("\(#function) finished all task")
      }
    }
  }

  @available(macOS 10.15, iOS 15.0, *)
  @Test func multipleOfMutex() async {
    let startDate = Date.now
    let mutex = AsyncMutexManager(mutexCount: 3)


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
        await mutex.waitForFinish()
        print("\(#function) finished all task")
      }
    }
    let endDate = Date.now
    #expect(Int(endDate.timeIntervalSince(startDate).rounded()) == 5)
  }
}
