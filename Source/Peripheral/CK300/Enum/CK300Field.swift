//
//  CK300Field.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 19/03/2019.
//

public enum CK300Field {    
    case bikeType
    case bikeSerialNumber
    case batterySerialNumber
    case bikeSoftwareVersion
    case controllerSoftwareVersion
    case displaySoftwareVersion
    case bikeDesignCapacity
    case wheelDiameter
    case bleVersion
    case airVersion
    
    case bikeStatus
    case bikeSpeed
    case bikeRange
    case bikeOdometer
    case bikeBatterySOC
    case bikeBatterySOCPercentage
    case bikeSupportMode
    case bikeLightStatus
    
    case gpsLatitude
    case gpsLongitude
    case gpsAltitude
    case gpsHDOP
    case gpsSpeed
    
    case bikeBatteryFCC
    case bikeBatteryFCCPercentage
    case bikeBatteryChargingCycles
    case bikeBatteryPackVoltage
    case bikeBatteryTemperature
    case bikeBatteryErrors
    case bikeBatteryState
    case backupBatteryVoltage
    case backupBatteryPercentage
    case bikeBatteryActualCurrent
    
    case bikeActualTorque
    case bikeWheelSpeed
    case motorPower
    case motorErrors
    case pedalCadence
    case pedalPower
    case receivedSignalStrength
}
