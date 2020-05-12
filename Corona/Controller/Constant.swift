//
//  Constant.swift
//
//

import Foundation
struct Constants {
    static var lang = ""
    
    static let appTitle = "Corona Map"
    static let appTitleAr = "خريطة انتشار كورونا"
    
    static let confirmedTitle = "Confirmed"
    static let confirmedTitleAr = "المصابون"
    
    static let recoveredTitle = "Recovered"
    static let recoveredTitleAr = "المتعافون"
    
    static let deathTitle = "Deaths"
    static let deathTitleAr = "المتوفون"
    
    static let totalTitle = "Total"
    static let totalTitleAr = "الإجمالي"
    
    static let worldWideTitle = "World Wide"
    static let worldWideTitleAr = "دول العالم"
 
    static let langTitle = "English"
    static let langTitleAr = "عربي"
    
    static let settingsTitle = "Settings"
    static let settingsTitleAr = "الإعدادات"
    
    static let changeToArTitle = "النسخة العربية"
    static let changeToEnTitle = "English Version"
    
    static let showCityArTitle = "اظهار المدن"
    static let hideCityArTitle = "إخفاء المدن"
    
    static let showCityEnTitle = "Show Cities"
    static let hideCityEnTitle = "Hide Citis"
    
    static let closeTitle = "Close"
    static let closeTitleAr = "إغلاق"
    
    static let okTitle = "Ok"
    static let okTitleAr = "موافق"
    
    static let cancelTitle = "Cancel"
    static let cancelTitleAr = "إلغاء"
    
    static let aboutTitle = "About us"
    static let aboutTitleAr = "عن التطبيق"
    
    static let updatingTitle = "Updating..."
    static let updatingTitleAr = "تحديث..."
    
    static let updateTitle = "Update Information"
    static let updateTitleAr = "تحديث المعلومات"
    
    static let chatTitle = "BashairBot"
    static let chatTitleAr = "بشاير بوت"
    
    static let sendTitle = "Send"
    static let sendTitleAr = "إرسال"
    
    static let statusTitle = "Status"
    static let statusTitleAr = "الحالة"
    
    static let countTitle = "Count"
    static let countTitleAr = "العدد"
    
    static let newTitle = "New"
    static let newTitleAr = "الجديدة"
    
    static let placeholderTitleAr = "تفضل بطرح سؤالك؟"
    static let placeholderTitle = "Please type your question?"
    
    static let noUpdateTitle = "Error the data was not updated"
    static let noUpdateTitleAr = "خطأ لم يتم تحديث المعلومات"
    
    static let information = "Information were collected from several international and domestic sources"
    static let informationAr = "تم جمع المعلومات من عدة مصادر دولية ومحلية"
        
}

class GlobalArray {
   static let shared = GlobalArray()
   var countriesTimeSeries = [CountriesTimeSeries]()
}
