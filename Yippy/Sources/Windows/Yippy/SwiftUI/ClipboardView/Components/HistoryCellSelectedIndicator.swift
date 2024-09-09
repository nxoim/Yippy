import Cocoa
import HotKey
import RxSwift
import RxRelay
import RxCocoa
import SwiftUI

struct HistoryCellSelectedIndicator : View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.accentColor, lineWidth: 2)
    }
}
