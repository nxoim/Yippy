import Cocoa
import HotKey
import RxSwift
import RxRelay
import RxCocoa
import SwiftUI

struct StyledHistoryViewCell: View {
    let item: HistoryItem
    let index: Int
    let isSelected: Bool
    let isRichText: Bool
    let onSelect: () -> Void
    let onCopy: () -> Void
    let onDelete: () -> Void
    let proxy: GeometryProxy

    var body: some View {
        HistoryCellView(item: item, proxy: proxy, usingItemRtf: isRichText)
            .background(
                Rectangle()
                    .fill(Color(NSColor.windowBackgroundColor))
                    .opacity(0.0)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 8)
            )
            .overlay {
                ZStack(alignment: .topLeading) {
                    HistoryCellShortcutHint(index: index, isSelected: isSelected)
                        .padding(.all, 8)

                    if (isSelected) { HistoryCellSelectedIndicator() }
                }
            }
            .onTapGesture(perform: onSelect)
            .contextMenu { HistoryCellContextButtons(onCopy: onCopy, onDelete: onDelete) }
            .id(item)
            .draggable(item)
    }
}