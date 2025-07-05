//
//  addMaterials.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-18.
//

// Future enhancements:
// Create a double bubble slider to specify price range. This eliminates the possibility of incorrectly selecting lower and upper bounds

import SwiftUI

struct addMaterials: View {
    @State private var addNew = true
    @State private var materialName: String = ""
    @State private var materialCost: Double = 0
    @State private var nameError = false
    @State private var addCost = false
    @State private var costToolTip = false
    @State private var addPlusSymbol = false
    @State private var selectedCategory: materialsStruc.CategoryType = .gear
    @Binding var materials: [materialsStruc]
    @Binding var cost: Double?
    
    let minPriceValue: Double = 0
    let maxPriceValue: Double = 250
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {  // Adjust spacing between elements
            
            if addNew {
                
                HStack {
                    Text("Pick type:")
                    Button(action: {
                        costToolTip.toggle()
                    }) {
                        Image(systemName: "questionmark.circle")
                    }
                }
                if costToolTip {
                    Text("What contributes to Quest cost?")
                        .font(.headline)
                    Text("Quest cost is influenced by factors such as transportation costs (think transit fares or vehicle fuel), costs associated with obtaining supplies, and food or accomodation costs.")
                    
                }
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(materialsStruc.CategoryType.allCases) { category in
                            Text(category.rawValue.capitalized).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
            
                
                VStack(alignment: .leading, spacing: 10) {
            
                    TextField("Name", text: $materialName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Toggle("Add cost amount?", isOn: $addCost)
                        .padding()
                    if addCost {
                        HStack {
                            if materialCost >= maxPriceValue {
                                Text("Cost Estimate: $\(Int(materialCost)) +")
                            } else {
                                Text("Cost Estimate: $\(Int(materialCost))")
                            }
                            Slider(value: $materialCost, in: minPriceValue...maxPriceValue, step: 1)
                                .accentColor(.green)
                        }
                    }
                    
                    if nameError {
                        Text("Please enter a name for the supply or cost!")
                            .font(.subheadline)
                            .foregroundColor(.white) // Text color
                            .padding()              // Inner padding
                            .background(Color.red)  // Red background
                            .cornerRadius(8)        // Rounded corners
                            .shadow(radius: 4)      // Optional shadow for better visibility
                    }
        
                    Button(action: {
                        // Ensure that materialName is not empty to avoid adding empty items
                        nameError = materialName.isEmpty
                        if nameError { return }
                        
                        var anotherMaterial: materialsStruc
                        if materialCost >= 0, addCost {
                            anotherMaterial = materialsStruc(material: materialName, cost: materialCost, category: selectedCategory)
                            if materialCost >= maxPriceValue {
                                addPlusSymbol = true
                            }
                            if let tempCost = cost {
                                cost = tempCost + materialCost
                            } else {
                                cost = materialCost
                            }
                        } else {
                            anotherMaterial = materialsStruc(material: materialName, category: selectedCategory)
                        }
                        materials.append(anotherMaterial)
                        addNew = false

                    }) {
                        HStack {
                            Spacer()
                            Text("Save")
                            Spacer()
                        }
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(8)
                    }
                    .padding(.top, 10)  // Add some space above the button
                }
                .padding()
            }
            
            if !materials.isEmpty {
                Text("Supplies:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 10)
            }
            
            ForEach(materials) { material in
                HStack {
                    if let materialCategory = material.category {
                        Text(materialCategory.displayName)
                            .font(.headline)
                    }
                    Spacer()
                    Text(material.material)
                        .font(.headline)
                    Spacer()
                    if let costOfMaterial = material.cost {
                        if costOfMaterial >= maxPriceValue {
                            Text("$\(Int(costOfMaterial)) +")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        } else {
                            Text("$\(Int(costOfMaterial))")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.vertical, 8) // Adds spacing between rows
            }
            
            if !addNew {
                Button(action: {
                    materialCost = 0
                    materialName = ""
                    addCost = false
                    selectedCategory = .gear
                    // Clearing out state variables for the addition of a new material
                    addNew = true
                }) {
                    HStack {
                        Spacer()
                        Text("Add new supplies or costs")
                        Spacer()
                    }
                    .padding()
                    .background(Color.cyan)
                    .cornerRadius(8)
                }
            }
            
            if let tempCostTwo = cost {
                if addPlusSymbol {
                    Text("Total Estimated Cost: $\(Int(tempCostTwo)) +")
                }
                else {
                    Text("Total Estimated Cost: $\(Int(tempCostTwo))")
                }
            } else {
                Text("Total Estimated Cost: Unspecified")
            }
            
            Divider()
            
        }
    }
}


struct addMaterials_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(materialsStruc.sampleData) { binding in
            AnyView(addMaterials(materials: binding, cost: .constant(5)))
        }
    }
}

// Helper struct to create a @State binding in a preview
struct StatefulPreviewWrapper<Value>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> AnyView

    init(_ value: Value, content: @escaping (Binding<Value>) -> AnyView) {
        self._value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
