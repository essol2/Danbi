//
//  MainHeaderView.swift
//  danbi
//
//  Created by 이은솔 on 2/1/26.
//

import Foundation
import SwiftUI

struct MainHeaderView: View {
    @Binding var showingSettings: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text("단비")
                    .font(.custom("MemomentKkukkukkR", size: 36))
                    .foregroundColor(.black)
                
                Text("나의 반려식물에게 내리는 단비")
                    .font(.custom("MemomentKkukkukkR", size: 18))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    .padding(.top, 8)
            }
            
            Spacer()
            
            // 설정 메뉴 버튼
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    .frame(width: 44, height: 44)
            }
        }
    }
}

#Preview {
    MainHeaderView(showingSettings: .constant(false))
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.93))
}
