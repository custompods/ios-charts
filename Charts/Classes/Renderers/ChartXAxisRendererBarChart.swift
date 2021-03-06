//
//  ChartXAxisRendererBarChart.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
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

open class ChartXAxisRendererBarChart: ChartXAxisRenderer
{
    internal weak var _chart: BarChartView!
    
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
        
        self._chart = chart
    }
    
    /// draws the x-labels on the specified y-position
    internal override func drawLabels(_ context: CGContext?, pos: CGFloat)
    {
        if (_chart.data === nil)
        {
            return
        }
        
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .center
        
        let labelAttrs = [NSFontAttributeName: _xAxis.labelFont,
            NSForegroundColorAttributeName: _xAxis.labelTextColor,
            NSParagraphStyleAttributeName: paraStyle] as [String : Any]
        
        let barData = _chart.data as! BarChartData
        let step = barData.dataSetCount
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if (_xAxis.isWordWrapEnabled)
        {
            labelMaxSize.width = _xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        let maxX = min(_maxX + 1, _xAxis.values.count)
        for i in stride(from: _minX, to: maxX, by: _xAxis.axisLabelModulus)
        {
            let label = i >= 0 && i < _xAxis.values.count ? _xAxis.values[i] : nil
            if (label == nil)
            {
                continue
            }
            
            position.x = CGFloat(i * step) + CGFloat(i) * barData.groupSpace + barData.groupSpace / 2.0
            position.y = 0.0
            
            // consider groups (center label for each group)
            if (step > 1)
            {
                position.x += (CGFloat(step) - 1.0) / 2.0
            }
            
            position = position.applying(valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                if (_xAxis.isAvoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == _xAxis.values.count - 1)
                    {
                        let width = label!.size(attributes: labelAttrs).width
                        
                        if (width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth)
                        {
                            position.x -= width / 2.0
                        }
                    }
                    else if (i == 0)
                    { // avoid clipping of the first
                        let width = label!.size(attributes: labelAttrs).width
                        position.x += width / 2.0
                    }
                }
                
                drawLabel(context, label: label!, xIndex: i, x: position.x, y: pos, align: .center, attributes: labelAttrs as! [String : NSObject], constrainedToSize: labelMaxSize)
            }
        }
    }
    
    fileprivate var _gridLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderGridLines(_ context: CGContext?)
    {
        if (!_xAxis.isDrawGridLinesEnabled || !_xAxis.isEnabled)
        {
            return
        }
        
        let barData = _chart.data as! BarChartData
        let step = barData.dataSetCount
        
        context!.saveGState()
        
        context!.setStrokeColor(_xAxis.gridColor.cgColor)
        context!.setLineWidth(_xAxis.gridLineWidth)
        if (_xAxis.gridLineDashLengths != nil)
        {
            context!.setLineDash(phase: _xAxis.gridLineDashPhase, lengths: _xAxis.gridLineDashLengths)
        }
        else
        {
            context!.setLineDash(phase: 0.0, lengths: [])
        }
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in stride(from: _minX, to: _maxX, by: _xAxis.axisLabelModulus)
        {
            position.x = CGFloat(i * step) + CGFloat(i) * barData.groupSpace - 0.5
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                _gridLineSegmentsBuffer[0].x = position.x
                _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTop
                _gridLineSegmentsBuffer[1].x = position.x
                _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
                context!.strokeLineSegments(between: _gridLineSegmentsBuffer)
            }
        }
        
        context!.restoreGState()
    }
}
