import SwiftUI

struct SwipeableRow<Content: View>: View {
    var maxSwipeDistance: CGFloat = 150
    var minRequiredSwipeDistance: CGFloat = 80
    
    let onDelete: () -> Void
    @ViewBuilder let content: () -> Content
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                Spacer()
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
                .padding(.trailing, 20)
            }
            
            content()
                .offset(x: -offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 { // left swipe
                                offset = min(-value.translation.width, maxSwipeDistance)
                            }
                        }
                        .onEnded { value in
                            if value.translation.width < -minRequiredSwipeDistance {
                                withAnimation(.spring()) { onDelete() }
                            } else {
                                offset = 0
                            }
                        }
                )
        }
        .animation(.spring(), value: offset)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}