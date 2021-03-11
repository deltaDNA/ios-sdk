internal extension DDNAImageMessage {
    @objc func fetchResourcesMock() {
        delegate.didReceiveResources(for: self)
    }
}
