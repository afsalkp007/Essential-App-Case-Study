//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 03/02/2024.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    URLProtocolStub.startInterceptingRequests()
  }
  
  override func tearDown() {
    super.tearDown()
    URLProtocolStub.stopInerceptingRequests()
  }
  
  func test_getFromURL_performsGETRequestWithURL() {
    let url = anyURL()
    let exp = expectation(description: "Wait for request")

    URLProtocolStub.observeRequests { request in
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")
      exp.fulfill()

    }

    makeSUT().get(from: url) { _ in }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURL_failsOnRequestError() {
    let requestedError = NSError(domain: "any error", code: 1)
    
    let receivedError = resultErrorFor(data: nil, response: nil, error: requestedError) as? NSError
    
    XCTAssertEqual(receivedError?.domain, requestedError.domain)
    XCTAssertEqual(receivedError?.code, requestedError.code)
  }
  
  func test_getFromURL_failsOnAllInvalidRepresentationCases() {
    XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
    XCTAssertNotNil(resultErrorFor (data: anyData(), response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor (data: anyData(), response: nil, error: anyNSError()))
    XCTAssertNotNil(resultErrorFor (data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultErrorFor (data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultErrorFor (data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultErrorFor (data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultErrorFor (data: anyData(), response: nonHTTPURLResponse(), error: nil))

  }
  
  func tes_getFromURL_suceedsOnHTTPURLResponseWithData() {
    let data = anyData()
    let response = anyHTTPURLResponse()
    
    let recevedValues = resultValuesFor(data: data, response: response, error: nil)
    
    XCTAssertEqual(recevedValues?.data, data)
    XCTAssertEqual(recevedValues?.response.url, response?.url)
    XCTAssertEqual(recevedValues?.response.statusCode, response?.statusCode)
  }
  
  func tes_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
    let response = anyHTTPURLResponse()
    
    let recevedValues = resultValuesFor(data: nil, response: response, error: nil)
    
    let emptyData = Data()
    XCTAssertEqual(recevedValues?.data, emptyData)
    XCTAssertEqual(recevedValues?.response.url, response?.url)
    XCTAssertEqual(recevedValues?.response.statusCode, response?.statusCode)
  }

  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
    
  private func anyData() -> Data {
    return Data("any data".utf8)
  }
    
  private func nonHTTPURLResponse() -> URLResponse {
    return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
  }
  
  private func anyHTTPURLResponse() -> HTTPURLResponse? {
    return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
  }
  
  private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {

    let result = resultFor(data: data, response: response, error: error, file: file, line: line)
    
    switch result {
    case let .success((data, response)):
      return (data, response)
    default:
      XCTFail("Expected failure", file: file, line: line)
      return nil
    }
  }
  
  private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
    
    let result = resultFor(data: data, response: response, error: error, file: file, line: line)
    
    switch result {
    case let .failure(error):
      return error
    default:
      XCTFail("Expected failure", file: file, line: line)
      return nil
    }
  }
  
  private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result? {
    URLProtocolStub.stub(data: data, response: response, error: error)
    let sut = makeSUT(file: file, line: line)
    let exp = expectation(description: "Wait for request")

    var receivedResult: HTTPClient.Result!
    sut.get(from: anyURL()) { result in
      receivedResult = result
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return receivedResult
  }
  
  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    private struct Stub {
    let data: Data?
        let response: URLResponse?
      let error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
      stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
      requestObserver = observer
    }
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInerceptingRequests() {
      URLProtocolStub.unregisterClass(URLProtocolStub.self)
      stub = nil
      requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    
    override func startLoading() {
      if let requestObserver = URLProtocolStub.requestObserver {
        client?.urlProtocolDidFinishLoading(self)
        return requestObserver(request)
      }
      if let data = URLProtocolStub.stub?.data {
              client?.urlProtocol(self, didLoad: data)
            }

      if let response = URLProtocolStub.stub?.response {
              client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
      
      if let error = URLProtocolStub.stub?.error {
        client?.urlProtocol(self, didFailWithError: error)
      }
      
      client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
  }
}
 
