//
//  LineScatterCandleRadarChartRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 29/7/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import UIKit

open class LineScatterCandleRadarChartRenderer: ChartDataRendererBase
{
    public override init(animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    /// Draws vertical & horizontal highlight-lines if enabled.
    /// :param: context
    /// :param: points
    /// :param: horizontal
    /// :param: vertical
    open func drawHighlightLines(_ context: CGContext?, point: CGPoint, set: LineScatterCandleChartDataSet)
    {
        // draw vertical highlight lines
        if set.isVerticalHighlightIndicatorEnabled
        {
            context!.beginPath()
            context!.move(to: CGPoint(x: point.x, y: viewPortHandler.contentTop))
            context!.addLine(to: CGPoint(x: point.x, y: viewPortHandler.contentBottom))
            context!.strokePath()
        }
        
        // draw horizontal highlight lines
        if set.isHorizontalHighlightIndicatorEnabled
        {
            context!.beginPath()
            context!.move(to: CGPoint(x: viewPortHandler.contentLeft, y: point.y))
            context!.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: point.y))
            context!.strokePath()
        }
    }
}
