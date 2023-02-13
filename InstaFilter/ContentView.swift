//
//  ContentView.swift
//  InstaFilter
//
//  Created by Floriano Fraccastoro on 10/02/23.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterSaturation = 0.5
    @State private var filterScale = 0.5
    @State private var filterRadius = 0.5
    @State private var showingFilter = false
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var processedImage: UIImage?

    let context = CIContext()

    var body: some View {
        NavigationView{
            VStack {
                ZStack{
                    Rectangle()
                        .fill(Color.secondary)
                    Text("Tap to select a picture")
                        .font(.headline)
                        .foregroundColor(.white)
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                VStack{
                    HStack{
                        Text("Intensity")
                        Slider(value: $filterIntensity)
                            .onChange(of: filterIntensity){ _ in
                                applyProcessing()
                            }
                            .disabled(!currentFilter.inputKeys.contains(kCIInputIntensityKey) || image == nil)
                    }
                    HStack{
                        Text("Saturation")
                        Slider(value: $filterSaturation)
                            .onChange(of: filterSaturation){ _ in
                                applyProcessing()
                            }
                            .disabled(!currentFilter.inputKeys.contains(kCIInputSaturationKey) || image == nil)
                    }
                    HStack{
                        Text("Scale")
                        Slider(value: $filterScale)
                            .onChange(of: filterScale){ _ in
                                applyProcessing()
                            }
                            .disabled(!currentFilter.inputKeys.contains(kCIInputScaleKey) || image == nil)
                    }
                    HStack{
                        Text("Radius")
                        Slider(value: $filterRadius)
                            .onChange(of: filterRadius){ _ in
                                applyProcessing()
                            }
                            .disabled(!currentFilter.inputKeys.contains(kCIInputRadiusKey) || image == nil)
                    }
                }
                
                HStack{
                    Button("Change filter"){
                        showingFilter = true
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(image == nil)
                        
                }
            }
            .padding()
            .navigationTitle("InstaFilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Filter", isPresented: $showingFilter){
                Group{
                    Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                    Button("Edges") { setFilter(CIFilter.edges()) }
                    Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                    Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                    Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                    Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                    Button("Vignette") { setFilter(CIFilter.vignette()) }
                    Button("Greyscale") { setFilter(CIFilter.colorControls()) }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    func loadImage(){
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save(){
        guard let processedImage = processedImage else { return }

        let imageSaver = ImageSaver()

        imageSaver.successHandler = {
            print("Success!")
        }

        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }

        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcessing(){
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputSaturationKey) { currentFilter.setValue(filterSaturation, forKey: kCIInputSaturationKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
