//
//  NoDataView.swift
//  danbi
//
//  Created by 이은솔 on 1/29/26.
//

import Foundation
import SwiftUI

struct NoDataView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icon
            Image(systemName: "leaf.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 0.55, green: 0.65, blue: 0.55).opacity(0.3))
            
            // Message
            VStack(spacing: 8) {
                Text("아직 반려식물이 없어요")
                    .font(.custom("MemomentKkukkukkR", size: 24))
                    .foregroundColor(.black)
                
                Text("첫 번째 식물을 추가해보세요")
                    .font(.custom("MemomentKkukkukkR", size: 16))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoDataView()
}
