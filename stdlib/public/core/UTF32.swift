//===--- UTF32.swift ------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
extension _Unicode {
  public enum UTF32 {
  case _swift3Codec
  }
}

extension _Unicode.UTF32 : UnicodeEncoding {
  public typealias CodeUnit = UInt32
  public typealias EncodedScalar = CollectionOfOne<UInt32>

  public static var encodedReplacementCharacter : EncodedScalar {
    return EncodedScalar(0xFFFD)
  }

  @inline(__always)
  public static func _isScalar(_ x: CodeUnit) -> Bool  {
    return true
  }

  @inline(__always)
  public static func decode(_ source: EncodedScalar) -> UnicodeScalar {
    return UnicodeScalar(_unchecked: source.first!)
  }

  @inline(__always)
  public static func encode(_ source: UnicodeScalar) -> EncodedScalar? {
    return EncodedScalar(source.value)
  }
  
  public struct Parser {
    public init() { }
  }
  
  public typealias ForwardParser = Parser
  public typealias ReverseParser = Parser
}

extension UTF32.Parser : UnicodeParser {
  public typealias Encoding = _Unicode.UTF32

  /// Parses a single Unicode scalar value from `input`.
  public mutating func parseScalar<I : IteratorProtocol>(
    from input: inout I
  ) -> _Unicode.ParseResult<Encoding.EncodedScalar>
  where I.Element == Encoding.CodeUnit {
    let n = input.next()
    if _fastPath(n != nil), let x = n {
      // Check code unit is valid: not surrogate-reserved and within range.
      guard _fastPath((x &>> 11) != 0b1101_1 && x <= 0x10ffff)
      else { return .invalid(length: 1) }
      
      // x is a valid scalar.
      return .valid(UTF32.EncodedScalar(x))
    }
    return .emptyInput
  }
}
