//
//  ActiveQuestView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-14.
//

import SwiftUI
import MapKit

struct ActiveQuestView: View {
    //@ObservedObject var viewModel: MapViewModel // RIGHT NOW I PASS THIS MODEL BUT DON"T USE IT FOR ANYTHING. IF NOT NEEDED, REMOVE. DOESNT APPEAR TO BE NEEDED AS WE CHECK FOR LOCATION SERVICES ENABLEMENT IN AN EARLIER VIEW
    @State private var bottomMenuExpanded = true
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic) // Should default to the objectiveArea??
    
    @State private var currentObjectiveIndex = 0
    @State private var enteredObjectiveSolution = ""
    @State private var showHintButton = false
    @State private var displayHint = false
    @State private var answerIsWrong = false
    @State private var answerIsRight = false
    @State var timerValue = 100 // Should be reset to the correct value on appear
    @State private var showTimer = false
    @State var timerIsUp = false // timer is up is a fail condition
    
    // Reporting for issues
    @State private var showReportText = false
    
    @ObservedObject var viewModel: ActiveQuestViewModel // passed in
    //@StateObject var viewModel = ActiveQuestViewModel(mapViewModel: nil)
    
    //let quest: QuestStruc // Not needed. We use the version held in the ActiveQuestViewModel
    var currentObjective: ObjectiveStruc {
        viewModel.quest.objectives[currentObjectiveIndex]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemCyan)
                    .ignoresSafeArea()
        
                VStack {
                    // Map view
                    Map(position: $position) {
                        UserAnnotation()
                        if let center = currentObjective.objectiveArea.center {
                            MapCircle(center: center, radius: currentObjective.objectiveArea.range)
                                .foregroundStyle(Color.cyan.opacity(0.5))
                            if let route = viewModel.route {
                                MapPolyline(route)
                                    .stroke(.blue, lineWidth: 5)
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .frame(width: UIScreen.main.bounds.width, height: bottomMenuExpanded ? 250 : 600)
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }
                    .accentColor(Color.cyan)

                    Spacer()
                    
                    // Bottom pop-up menu
                    if bottomMenuExpanded {
                        bottomMenu
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: bottomMenuExpanded)
                    } else {
                        smallIndicator
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: bottomMenuExpanded)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
               
                VStack {
                    /* Ensures that the objective does have a timer value as a condition for displaying a timer */
                    if showTimer {
                        timerView(timerValue: $timerValue, timerIsUp: $timerIsUp, questCompletedStopTimer: $viewModel.showQuestCompletedView)
                            .padding()
                    }
                    
                    // Directions button UI
                    if let center = currentObjective.objectiveArea.center {
                        if let directionsErrorMessage = viewModel.objectiveAreaDirectionsErrorMessage {
                            Text(directionsErrorMessage)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.red) // Red background
                                )
                                .padding(.horizontal)
                        }
                        else {
                            HStack {
                                Button(action: {
                                    viewModel.getDirections(startingLocDirections: false, startCoordinate: center) // view model
                                    viewModel.showProgressView = true
                                }) {
                                    HStack {
                                        Text("Get directions to objective area")
                                            .fontWeight(.medium)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                            .shadow(radius: 5)
                                            .foregroundColor(.blue)
                                        if viewModel.showProgressView {
                                            ProgressView()
                                                .padding()
                                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                                .shadow(radius: 5)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                }
                
                //Overlay for correct answers
                Color(answerIsRight ? .green.opacity(0.2) : .clear)
                    .animation(.easeInOut(duration: 0.3), value: answerIsWrong)
                    .ignoresSafeArea()
                
                // Overlay for incorrect answers
                Color(answerIsWrong ? .red.opacity(0.5) : .clear)
                    .animation(.easeInOut(duration: 0.3), value: answerIsWrong)
                    .ignoresSafeArea()
                
            }
            .navigationDestination(isPresented: $viewModel.showQuestCompletedView) {
                QuestCompleteView(viewModel: viewModel)
            }
            .onAppear {
                updateTimerValue()
                viewModel.route = nil
                viewModel.objectiveAreaDirectionsErrorMessage = nil
                viewModel.showProgressView = false
            }
            .onChange(of: timerIsUp) {
                if timerIsUp == true {
                    // The quest has been failed
                    // Order matters here to set fail BEFORE questCompleteView!!
                    viewModel.fail = true
                    viewModel.showQuestCompletedView = true
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .ignoresSafeArea()
    }
    
    private var bottomMenu: some View {
        ScrollView {
            VStack(spacing: 10) { // Adjust spacing for better layout
                Button(action: {
                    withAnimation {
                        bottomMenuExpanded.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.down")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        Text("Close Menu")
                            .font(.subheadline)
                    }
                }
                .padding(.top)

                Divider()
                
                Text(currentObjective.objectiveTitle)
                    .font(.headline)
                    .padding()

                Text(currentObjective.objectiveDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()

                if(currentObjective.objectiveType == .code) {
                    HStack {
                        Text("Enter Solution:")
                        TextField("Solution", text: $enteredObjectiveSolution)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 10)
                    }
                    .padding(.bottom)
                } else {
                    Text("Enter Solution: \(enteredObjectiveSolution)")
                    NumericGrid(solutionCombinationAndCode: $enteredObjectiveSolution)
                        .padding(.leading, 10)
                }

                if answerIsWrong {
                    Text("Answer Incorrect")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: answerIsWrong)
                }
                
                if answerIsRight {
                    Text("Correct")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 5)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: answerIsRight)
                }

                Button(action: {
                    checkSolution()
                }) {
                    Text("Check Solution")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
                .padding(.vertical)

                if showHintButton {
                    Button(action: {
                        displayHint = true
                    }) {
                        HStack {
                            Text("Get a hint")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom)
                }
                
                if displayHint {
                    if let hint = currentObjective.objectiveHint {
                        Text(hint)
                            .font(.caption)
                            .foregroundColor(.black)
                            .padding(.top, 5)
                    }
                }
                
                // Progress bar
                ProgressView(value: Double(currentObjectiveIndex + 1), total: Double(viewModel.quest.objectives.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.vertical, 20)
                
                Button(action: {
                    viewModel.showActiveQuestView = false
                }) {
                    Text("Exit Active Quest")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
                
                Menu {
                    Button("Incomplete", action: {
                        showReportText = true
                        viewModel.reportType = .incomplete
                        print("Selected: Incomplete")
                    })
                    Button("Inappropriate", action: {
                        showReportText = true
                        viewModel.reportType = .inappropriate
                        print("Selected: Inappropriate")
                    })
                    Button("Other", action: {
                        showReportText = true
                        viewModel.reportType = .other
                        print("Selected: Other")
                    })
               } label: {
                   HStack {
                       Image(systemName: "exclamationmark.triangle.fill")
                           .foregroundColor(.red)
                       Text("Report")
                           .font(.subheadline)
                           .fontWeight(.bold)
                           .foregroundColor(.red)
                   }
                   .padding()
                }
                
                if showReportText {
                    VStack {
                        Text("Describe issue: ")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                        HStack {
                            TextField("Describe the issue...", text: $viewModel.reportText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            Button("Submit") {
                                // Handle the submission
                                print("Report: \(viewModel.reportText)")
                                showReportText = false
                                viewModel.addReportRelationship(questId: viewModel.quest.id.uuidString)
                                
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 800)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
    
    private var smallIndicator: some View {
        VStack {
            Image(systemName: "chevron.up")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("Tap to Expand")
                .font(.subheadline)
                .padding()
            
            Divider()
            
            Text(currentObjective.objectiveTitle)
                .font(.headline)
            
            Text(currentObjective.objectiveDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            
            Spacer().frame(height: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color.white)
        .cornerRadius(16)
        .onTapGesture {
            withAnimation {
                bottomMenuExpanded.toggle()
            }
        }
    }
    
    private func checkSolution() {
        if enteredObjectiveSolution == currentObjective.solutionCombinationAndCode {
            // Objective has successfully been completed, can move on to the next objective
            if currentObjectiveIndex == viewModel.quest.objectives.count - 1 {
                viewModel.showQuestCompletedView = true // Quest completed
            }
            if currentObjectiveIndex + 1 < viewModel.quest.objectives.count {
                currentObjectiveIndex += 1
                enteredObjectiveSolution = ""
                showHintButton = false // reset showHintButton to false
                viewModel.route = nil // Reset the directions route for the next objective
                viewModel.objectiveAreaDirectionsErrorMessage = nil // Reset the directions error message for the next objective
                viewModel.showProgressView = false // Reset the progress view to false for the next objective
                updateTimerValue() // Reset the timer for the new objective
            }
            
            answerIsRight = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                answerIsRight = false
            }
            
            
        } else {
            // Answer is wrong
            answerIsWrong = true
            if let _ = currentObjective.objectiveHint {
                // There is a hint associated with this objective
                showHintButton = true
            }
            else {
                showHintButton = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                answerIsWrong = false
            }
        }
    }
    
    private func updateTimerValue() {
        if !(currentObjective.hoursConstraint == nil && currentObjective.minutesConstraint == nil) {
            // Both are not nil, so we can show a constraint
            let objectiveHoursConstraint = currentObjective.hoursConstraint ?? 0
            let objectiveMinutesConstraint = currentObjective.minutesConstraint ?? 0
            timerValue = objectiveHoursConstraint * 3600 + objectiveMinutesConstraint * 60
            showTimer = true
        }
        else {
            showTimer = false
        }
    }
}

struct ActiveQuestView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveQuestView(viewModel: ActiveQuestViewModel(mapViewModel:  nil, initialQuest: QuestStruc.sampleData[0]))
    }
}
