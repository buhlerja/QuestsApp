//
//  timerView.swift
//  Quests
//
//  Created by Jack Buhler on 2024-10-26.
//

import SwiftUI

struct timerView: View {
    @State private var duration = "---"
    @Binding var timerIsUp: Bool
    @Binding var questCompletedStopTimer: Bool
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Binding var timerValue: Int // Parameter to specify the countdown duration in seconds
    
    private let desiredDuration: Date // Target time for countdown

    init(timerValue: Binding<Int>, timerIsUp: Binding<Bool>, questCompletedStopTimer: Binding<Bool>) {
        self._questCompletedStopTimer = questCompletedStopTimer
        self._timerIsUp = timerIsUp // Initialize the @Binding property
        self._timerValue = timerValue
        self.desiredDuration = Calendar.current.date(byAdding: .second, value: timerValue.wrappedValue, to: Date())!
    }
    
    static var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Spacer()
                Text(duration)
                    .font(.system(size: 18, weight: .bold))
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(6)
                Spacer()
            }
        }
        .frame(width: 300, height: 34)
        .onReceive(timer) { _ in
            var delta = desiredDuration.timeIntervalSince(Date())
            if delta <= 0 {
                delta = 0
                timerIsUp = true // let the parent view know that the timer is up
                //timer.upstream.connect().cancel() // No need to cancel timer here since change in timerIsUp changes questCompletedStopTimer in parent view which stops timer
            }
            timerValue -= 1
            duration = timerView.durationFormatter.string(from: delta) ?? "---"
        }
        .onChange(of: questCompletedStopTimer) {
            if questCompletedStopTimer {
                timer.upstream.connect().cancel() // Stop the timer when questCompletedStopTimer becomes true. Executes for both passes and fails
            }
        }
    }
}

struct timerView_Previews: PreviewProvider {
    static var previews: some View {
        timerView(timerValue: .constant(5), timerIsUp: .constant(false), questCompletedStopTimer: .constant(false)) // Example usage with a 5-second countdown
    }
}


