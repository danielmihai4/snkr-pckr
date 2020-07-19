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
        
        config.colors.tintColor = UIColor.black
        config.colors.navigationBarActivityIndicatorColor = UIColor.black
        config.colors.multipleItemsSelectedCircleColor = UIColor.black
        config.colors.photoVideoScreenBackgroundColor = UIColor.black
        config.colors.libraryScreenBackgroundColor = UIColor.black
        config.colors.safeAreaBackgroundColor = UIColor.black
        config.colors.assetViewBackgroundColor = UIColor.black
        config.colors.filterBackgroundColor = UIColor.black
        config.colors.bottomMenuItemBackgroundColor = UIColor.black
        config.colors.bottomMenuItemSelectedTextColor = UIColor.black
        config.colors.bottomMenuItemUnselectedTextColor = UIColor.black
        config.colors.trimmerMainColor = UIColor.black
        config.colors.trimmerHandleColor = UIColor.black
        config.colors.positionLineColor = UIColor.black
        config.colors.coverSelectorBorderColor = UIColor.black
        config.colors.progressBarTrackColor = UIColor.black
        config.colors.progressBarCompletedColor = UIColor.black
        
        return config
    }
}
