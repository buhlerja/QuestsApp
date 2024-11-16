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
    @State private var materialCostLowerBound: Double = 0
    @State private var materialCostUpperBound: Double = 10
    @State private var rangeError = false
    @State private var nameError = false
    @Binding var materials: [materialsStruc]
    
    let minPriceValue: Double = 0
    let maxPriceValue: Double = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {  // Adjust spacing between elements
            
            if addNew {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Name of Item")
                        TextField("Name", text: $materialName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Cost Lower Bound: \(Int(materialCostLowerBound))")
                        Slider(value: $materialCostLowerBound, in: minPriceValue...maxPriceValue, step: 1)
                            .accentColor(.green)
                    }
                    
                    HStack {
                        Text("Cost Upper Bound: \(Int(materialCostUpperBound))")
                        Slider(value: $materialCostUpperBound, in: minPriceValue...maxPriceValue, step: 1)
                            .accentColor(.green)
                    }
                    
                    if rangeError {
                        Text("Please ensure that the price lower bound is less than the price upper bound!")
                    }
                    
                    if nameError {
                        Text("Please enter a name for the equipment!")
                    }
        
                    Button(action: {
                        // Ensure that materialName is not empty to avoid adding empty items
                        nameError = materialName.isEmpty
                        if nameError { return }
                        
                        rangeError = materialCostLowerBound >= materialCostUpperBound
                        if rangeError { return }
                        
                        let anotherMaterial = materialsStruc(material: materialName, costLowerBound: materialCostLowerBound, costUpperBound: materialCostUpperBound)
                        materials.append(anotherMaterial)
                        addNew = false

                    }) {
                        HStack {
                            Spacer()
                            Text("Save")
                            Spacer()
                        }
                        .background(Color.cyan)
                        .cornerRadius(8)
                    }
                    .padding(.top, 10)  // Add some space above the button
                }
                .padding()
            }
            
            if !addNew {
                Button(action: {
                    materialCostLowerBound = 0
                    materialCostUpperBound = 10
                    materialName = ""
                    // Clearing out state variables for the addition of a new material
                    addNew = true
                }) {
                    HStack {
                        Spacer()
                        Text("Add New Supplies and Equipment")
                        Spacer()
                    }
                    .background(Color.cyan)
                    .cornerRadius(8)
                }
            }
            
            /*List {
                ForEach(materials) { material in
                    Text("\(material.material) - $\(Int(material.cost))")
                        .foregroundColor(Color.black)
                }
            }
            .listStyle(PlainListStyle())  // Use a plain list style to reduce extra padding
            .frame(maxHeight: 200)  // Constrain the height of the list to 200 points
            
            .padding(.top, addNew ? 0 : 20)  // Add more space only when "Add New Material" button is alone*/
            
            ForEach(materials) { material in
               HStack {
                   Text(material.material)
                       .font(.headline)
                   Spacer()
                   Text("$\(Int(material.costLowerBound)) - $\(Int(material.costUpperBound))")
                       .font(.subheadline)
               }
               .padding()
            }
        
        }
        .padding()
    }
}


struct addMaterials_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(materialsStruc.sampleData) { binding in
            AnyView(addMaterials(materials: binding))
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
