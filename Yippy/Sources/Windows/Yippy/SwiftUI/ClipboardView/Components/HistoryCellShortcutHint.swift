import Cocoa
import HotKey
import RxSwift
import RxRelay
import RxCocoa
import SwiftUI

struct HistoryCellShortcutHint : View {
    let index: Int
    let isSelected: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            if index < 10 {
                VStack {
                    HStack {
                        Spacer()
                        Text("􀆔 + \(index)")
                            .font(.system(size: 10))
                            .padding(.all, 4)
                            .foregroundStyle(Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.accentColor)
                            )
                    }
                    
                    Spacer()
                }
            }
        }
    }
}