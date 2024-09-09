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

struct YippyView : View {
    @Bindable var viewModel = YippyViewModel()
    @FocusState private var focusState: Focus?
    @Environment(\.controlActiveState) var controlActiveState
    let onCloseRequest: () -> Void
    @AppStorage("clipboardoffsetx") private var offsetX: Double = 0
    @AppStorage("clipboardoffsety") private var offsetY: Double = 0
    
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
