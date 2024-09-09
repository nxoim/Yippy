import Cocoa
import HotKey
import RxSwift
import RxRelay
import RxCocoa
import SwiftUI

struct HistoryCellContextButtons : View {
    let onCopy: () -> Void
    let onDelete: () -> Void
    
    var body : some View {
        Button(action: onCopy) {
            Label("Copy", systemImage: "document.on.document")
        }
        
        Button(action: onDelete) {
            Label("Delete", systemImage: "trash")
        }
    }
}
