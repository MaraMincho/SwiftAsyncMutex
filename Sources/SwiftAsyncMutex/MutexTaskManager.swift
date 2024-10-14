//
//  File 2.swift
//  
//
//  Created by MaraMincho on 9/1/24.
//

import Foundation
import Combine

@available(macOS 10.15, iOS 13.0, *)
public actor AsyncMutexManager: Equatable, Identifiable, Sendable {
  public static func == (lhs: AsyncMutexManager, rhs: AsyncMutexManager) -> Bool {
    lhs.id == rhs.id
  }
  nonisolated public let id: UUID = .init()

  private var isFinishPublisher: PassthroughSubject<Void, Never> = .init()
  private var justOneMutexFinishPublisher: PassthroughSubject<Int, Never> = .init()

  private let initialTaskCount: Int
  private var currentTaskCount: Int
  private var historyTaskCount: Int
  private var willHistoryTaskCount: Int

  public init(mutexCount: Int = 2) {
    self.initialTaskCount = mutexCount
    self.currentTaskCount = mutexCount
    historyTaskCount = 0
    willHistoryTaskCount = 0
  }

  public func willTask() async {
    let myTaskCount = willHistoryTaskCount
    willHistoryTaskCount += 1

    if currentTaskCount == 0 {
      var cancellable: AnyCancellable?
      await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        cancellable = justOneMutexFinishPublisher.sink { val in
          if myTaskCount == val {
            continuation.resume(returning: ())
          }
        }
      }
      cancellable = nil
    }
    currentTaskCount -= 1
  }

  public func didTask() {
    currentTaskCount += 1
    historyTaskCount += 1
    justOneMutexFinishPublisher.send(historyTaskCount)
    if historyTaskCount == willHistoryTaskCount {
      isFinishPublisher.send()
    }
  }

  public func waitForFinish() async -> Void {
    return await withCheckedContinuation { continuation in
      var cancellable: AnyCancellable?
      cancellable = isFinishPublisher
        .sink(receiveCompletion: { _ in
        }, receiveValue: { output in
          continuation.resume(with: .success(()))
          cancellable?.cancel()
        })
    }
  }
}
