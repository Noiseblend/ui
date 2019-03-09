import React from 'react'

import config from '~/config'

appleDevices = {
    iPhone5: {
        width:  320
        height: 568
        pixelRatio: 2
    }
    iPhone876s6: {
        width:  375
        height: 667
        pixelRatio: 2
    }
    iPhone876s6Plus: {
        width:  414
        height: 736
        pixelRatio: 3
    }
    iPhoneX: {
        width:  375
        height: 812
        pixelRatio: 3
    }
    iPadMiniAir: {
        width:  768
        height: 1024
        pixelRatio: 2
    }
    iPadPro10: {
        width:  834
        height: 1112
        pixelRatio: 2
    }
    iPadPro13: {
        width: 1024
        height: 1366
        pixelRatio: 2
    }
}

AppleLaunchScreenLinks = ({ topic }) ->
    for name, device of appleDevices
        <link
            key={ name }
            rel="apple-touch-startup-image"
            media="
                (device-width: #{ device.width }px) and
                (device-height: #{ device.height }px) and
                (-webkit-device-pixel-ratio: #{ device.pixelRatio })"
            href="\
                #{ config.STATIC }/img/launch-screens/\
                #{ topic }/#{ topic }-apple-launch-\
                #{ device.width }x\
                #{ device.height }\
                @#{ device.pixelRatio }x.png"
        />

export default AppleLaunchScreenLinks
