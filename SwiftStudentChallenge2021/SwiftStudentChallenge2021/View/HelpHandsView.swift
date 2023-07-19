import Foundation
import UIKit
import SwiftUI

class HandsHelpViewModel {
    var closeAction: () -> Void = {}
}

struct HelpHandsView: View {
    
    var model: HandsHelpViewModel
    
    var body: some View {
                
        let dict = ["✊": "0", "✌️🤚": "7", "☝️":"1", "✌️":"2", "☝️☝️":"2"]
        
        ZStack {
                        
            Color.white
                .ignoresSafeArea()
                .cornerRadius(15)
            
            VStack (alignment: .center, spacing: 16) {
                                
                VStack(alignment: .center, spacing: 5) {
                    
                    VStack {
                        EmoticonHandsView()
                        Text("Use your hands!")
                            .font(Font.custom("Arial Rounded MT Bold", size: 33))
                            .foregroundColor(.black)
                    }
                    
                    Text("Show to the camera your hands! Each lifted finger is equal to 1.")
                        .font(Font.custom("Arial Rounded MT Bold", size: 24))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding([.leading, .trailing])
                }
                .padding([.trailing, .leading], 20)
                
                Text("Some examples")
                    .font(Font.custom("Arial Rounded MT Bold", size: 28))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                List {
                    ForEach(dict.sorted(by: >), id: \.key) { key, value in
                        CellView(emoticonString: key, numberString: value)
                    }
                    .listRowBackground(Color.white)
                }
                .background(Color.white)
                .frame(height: 255)
                .onAppear {
                    UITableView.appearance().isScrollEnabled = false
                }
                
                Button(action: {
                    self.model.closeAction()
                }) {
                    Text("Got it!")
                        .font(Font.custom("Arial Rounded MT Bold", size: 30))
                        .foregroundColor(Color.white)
                        .frame(width: 180 , height: 50, alignment: .center)
                        .background(Color(Colors.blue))
                        .foregroundColor(.black)
                }
                .cornerRadius(40)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 0)
                
            }
            .frame(width: 460, height: 600, alignment: .center)
        }
    }
}

struct EmoticonHandsView: View {
    
    private let array = ["✌️🤚", "🖐", "☝️", "🖐☝️", "✊", "🖐👆", "🖖", "🤟"]
    private let timer = Timer.publish(every: 1.2, on: .main, in: .default).autoconnect()
    @State private var textValue = "🖐"
    @State private var num = 0
    
    var body: some View {
        Text(textValue)
            .font(Font.custom("Arial Rounded MT Bold", size: 45))
            .foregroundColor(Color.white)
            .onReceive(timer) { input in
                textValue = array[num]
                num += 1
                if num == array.count - 1 {
                    num = 0
                }
            }
    }
    
}

struct CellView: View {
    
    var emoticonString: String
    var numberString: String
    
    var body: some View {
        
        ZStack {
            Color.white.ignoresSafeArea()
            HStack (alignment: .center, spacing: 20) {
                Spacer()
                Text(emoticonString)
                    .font(Font.custom("Arial Rounded MT Bold", size: 30))
                    .frame(width: 60, height: 40, alignment: .center)
                    .foregroundColor(Color.black)
                
                Text("➜")
                    .font(Font.custom("Arial Rounded MT Bold", size: 30))
                    .frame(width: 60, height: 40, alignment: .center)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.black)
                
                Text(numberString)
                    .font(Font.custom("Arial Rounded MT Bold", size: 30))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.black)
                Spacer()
            }
        }
    }
}
