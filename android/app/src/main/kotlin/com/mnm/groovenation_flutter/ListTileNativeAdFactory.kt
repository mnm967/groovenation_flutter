package com.mnm.groovenation_flutter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.MediaContent
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import com.mnm.groovenation.R
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class ListTileNativeAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
            nativeAd: NativeAd,
            customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
                .inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        with(nativeAdView) {
            val iconView = findViewById<ImageView>(R.id.icon)
            val icon = nativeAd.icon

            if (icon != null) iconView.setImageDrawable(icon.drawable)
            this.iconView = iconView

            val headlineView = findViewById<TextView>(R.id.primary)
            headlineView.text = nativeAd.headline
            this.headlineView = headlineView

            val bodyView = findViewById<TextView>(R.id.secondary)
            with(bodyView) {
                text = nativeAd.body
                visibility = if (nativeAd.body.isNotEmpty()) View.VISIBLE else View.INVISIBLE
            }
            this.bodyView = bodyView

            val mediaView = findViewById<MediaView>(R.id.media_view)
            if(nativeAd.mediaContent != null) mediaView.setMediaContent(nativeAd.mediaContent as MediaContent)
            else mediaView.visibility = View.GONE

            val sponsoredText = findViewById<TextView>(R.id.ad_notification_view)
            with(sponsoredText){
                text = "Sponsored"
            }

            setNativeAd(nativeAd)
        }

        return nativeAdView
    }
}
