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