//
//  PickerConfiguration.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 04/04/2020.
//  Copyright © 2020 Daniel Mihai. All rights reserved.
//

import Foundation
import YPImagePicker

class PickerConfiguration {
    
    static func configuration() -> YPImagePickerConfiguration {
        var config = YPImagePickerConfiguration()
        
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = false
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = true
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = YPPickerScreen.library
        config.screens = [.photo, .library]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = true
        if #available(iOS 13.0, *) {
            config.preferredStatusBarStyle = UIStatusBarStyle.darkContent
        } else {
            config.preferredStatusBarStyle = UIStatusBarStyle.default
        }
        
        config.colors.tintColor = Colors.umber
        config.colors.navigationBarActivityIndicatorColor = Colors.umber
        config.colors.multipleItemsSelectedCircleColor = Colors.umber
        config.colors.photoVideoScreenBackgroundColor = Colors.umber
        config.colors.libraryScreenBackgroundColor = Colors.umber
        config.colors.safeAreaBackgroundColor = Colors.umber
        config.colors.assetViewBackgroundColor = Colors.umber
        config.colors.filterBackgroundColor = Colors.umber
        config.colors.bottomMenuItemBackgroundColor = Colors.umber
        config.colors.bottomMenuItemSelectedTextColor = Colors.umber
        config.colors.bottomMenuItemUnselectedTextColor = Colors.umber
        config.colors.trimmerMainColor = Colors.umber
        config.colors.trimmerHandleColor = Colors.umber
        config.colors.positionLineColor = Colors.umber
        config.colors.coverSelectorBorderColor = Colors.umber
        config.colors.progressBarTrackColor = Colors.umber
        config.colors.progressBarCompletedColor = Colors.umber
        
        return config
    }
}
