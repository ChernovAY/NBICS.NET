//
//  WebApi.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 29.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation

public class WebApi {
    
    public static let MainDomen: String = "http://nbics.net/"
    
    /** Получить капчу */
    public static let CaptchaApi: String = WebApi.MainDomen + "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/CaptchaGet"
    
    /** Зарегистрировать пользователя */
    public static let RegistrationApi: String = WebApi.MainDomen + "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/Registration"
    
    /** Вход в систему */
    public static let LoginApi: String = WebApi.MainDomen + "Account/Login"
    
    /** Список контактов */
    public static let ContatcsApi: String = WebApi.MainDomen + "VSM.Web.Plugins.Contacts/ContactsHome/GetContactsAPI"
    
    /** Аватар юзера */
    public static let UserContactAvatar: String = WebApi.MainDomen + "VSM.Web.Plugins.Contacts/ContactsHome/GetContactsPhotosByUrlAPI"

}
