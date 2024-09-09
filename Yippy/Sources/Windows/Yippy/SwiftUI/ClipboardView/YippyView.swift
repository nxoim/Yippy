//
//  YippyView.swift
//  Yippy
//
//  Created by v.prusakov on 2/13/24.
//  Copyright © 2024 MatthewDavidson. All rights reserved.
//

import Cocoa
import HotKey
import RxSwift
import RxRelay
import RxCocoa
import SwiftUI

class SUIYippyViewController: NSHostingController<YippyView> {
    required init?(coder: NSCoder) {
        super.init(
            coder: coder,
            rootView: YippyView(
                onCloseRequest: {
                    print("close request") // todo, is it even possible this way
                }
            )
        )
    }
    
    
}

enum Focus {
    case searchbar
}

struct YippyView : View {
    @Bindable var viewModel = YippyViewModel()
    @FocusState private var focusState: Focus?
    @Environment(\.controlActiveState) var controlActiveState
    let onCloseRequest: () -> Void
    @SwiftUI.State private var offsetX: CGFloat = 0
    @SwiftUI.State private var offsetY: CGFloat = 0
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack() {
                    Spacer(minLength: 12)

                    GrabHandle()
                        
                    Spacer(minLength: 16)
                    
                    SearchBar(viewModel: viewModel)
                        .padding(.horizontal, 16)
                        .focused($focusState, equals: .searchbar)

                    Spacer(minLength: 4)

                    HistoryTableView(viewModel: viewModel)
                        .onAppear(perform: viewModel.onAppear)
                }
                .frame(width: 400, height: 700)
                .contentMargins(.vertical, 16)
            }
            .materialBlur(style: .popover)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(radius: 16)
            .onChange(of: viewModel.isSearchBarFocused) { _, newValue in
                if newValue == true {
                    self.focusState = .searchbar
                } else {
                    self.focusState = nil
                }
            }
            .padding(.all, 32)
            .onChange(of: controlActiveState) { activeState in
                // if inactive
                if (activeState != .key) { onCloseRequest() }
            }
            .gesture(
                DragGesture(coordinateSpace: .global)
                    // workaround for dragging. everything else seemed to be buggy. TODO
                    .onChanged { gesture in
                        offsetX = offsetX + (gesture.velocity.width / 230)
                        offsetY = offsetY + (gesture.velocity.height / 230)
                    }
            )
            .offset(x: offsetX, y: offsetY)
            
            // we need all of the space.
            // without this the view gets clipped where shadow ends
            Spacer()
                .frame(width: .infinity, height: .infinity)
        }
    }
}

struct GrabHandle : View {
    var body : some View {
        Rectangle()
            .fill(Color.white)
            .opacity(0.4)
            .frame(width: 64, height: 4)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SearchBar : View {
    @Bindable var viewModel: YippyViewModel
    
    var body : some View {
        TextField(
            text: $viewModel.searchBarValue,
            prompt: Text("Search")
        ) {
            Image(systemName: "magnifyingglass")
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .onChange(of: viewModel.searchBarValue) { _, _ in
            viewModel.runSearch()
        }
    }
}

struct HistoryTableView: View {
    
    @Bindable var viewModel: YippyViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { reader in
                ScrollView(viewModel.panelPosition) {
                    if viewModel.panelPosition == .horizontal {
                        LazyHStack(spacing: 12) {
                            content(proxy: proxy)
                        }
                    } else {
                        LazyVStack(spacing: 4) {
                            content(proxy: proxy)
                                .padding(.top, 8)
                        }
                    }
                }
                .onChange(of: viewModel.selectedItem) { oldValue, newValue in
                    if let value = newValue {
                        reader.scrollTo(value)
                    }
                }
            }
        }
        .environment(\.historyCellSettings, HistoryCellSettings())
    }
    
    func content(proxy: GeometryProxy) -> some View {
        ForEach(Array(viewModel.yippyHistory.items.enumerated()), id: \.element) { (index, item) in
            StyledHistoryViewCell(
                item: item,
                index: index,
                isSelected: viewModel.selectedItem == item,
                isRichText: viewModel.isRichText,
                onSelect: { viewModel.onSelectItem(at: index) },
                onCopy: { viewModel.paste(at: index) },
                onDelete: { viewModel.delete(at: index) },
                proxy: proxy
            )
        }
    }
}

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

struct HistoryCellSelectedIndicator : View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.accentColor, lineWidth: 2)
    }
}

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
