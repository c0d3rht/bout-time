import AudioToolbox

class SoundEffectsPlayer {
    
    var sound: SystemSoundID = 0
    var soundEffectName = ""
    var soundEffectURL: URL {
        let path = Bundle.main.path(forResource: soundEffectName, ofType: "wav")!
        return URL(fileURLWithPath: path)
    }
    
    func playSound(status: Bool) {
        soundEffectName = status ? "AccessGranted" : "AccessDenied"
        let soundURL = soundEffectURL as CFURL
        AudioServicesCreateSystemSoundID(soundURL, &sound)
        AudioServicesPlaySystemSound(sound)
    }
    
}
