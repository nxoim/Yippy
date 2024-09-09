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
