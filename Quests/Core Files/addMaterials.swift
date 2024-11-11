//
//  addMaterials.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-18.
//

import SwiftUI

struct addMaterials: View {
    @State private var addNew = true
    @State private var materialName: String = ""
    @State private var materialCost: Double = 5
    @Binding var materials: [materialsStruc]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {  // Adjust spacing between elements
            
            if addNew {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Material Name")
                        TextField("Name", text: $materialName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Material Cost")
                        Slider(value: $materialCost, in: 1...10, step: 1)
                    }
        
                    Button(action: {
                        // Ensure that materialName is not empty to avoid adding empty items
                        guard !materialName.isEmpty else { return }
                        
                        let anotherMaterial = materialsStruc(material: materialName, cost: materialCost)
                        materials.append(anotherMaterial)
                        addNew = false
                        for material in materials {
                            print("Material: \(material.material), Cost: \(material.cost)")
                        }

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
                    addNew = true
                }) {
                    HStack {
                        Spacer()
                        Text("Add New Material")
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
                   Text("$\(Int(material.cost))")
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
