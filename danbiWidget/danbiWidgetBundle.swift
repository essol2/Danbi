//
//  danbiWidgetBundle.swift
//  danbiWidget
//
//  Created by 이은솔 on 2/2/26.
//

import WidgetKit
import SwiftUI

@main
struct danbiWidgetBundle: WidgetBundle {
    var body: some Widget {
        danbiWidget()
        danbiWidgetControl()
        danbiWidgetLiveActivity()
    }
}
