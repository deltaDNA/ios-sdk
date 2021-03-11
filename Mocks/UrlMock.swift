class UrlMock: NSURL {
    public var lastPathComponentWillReturn: String = ""
    
    override public var lastPathComponent: String {
        return lastPathComponentWillReturn
    }
}
