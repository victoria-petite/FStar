(*
   Copyright 2008-2018 Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
module FStar.Int.Cast

module U8  = FStar.UInt8
module U16 = FStar.UInt16
module U32 = FStar.UInt32
module U63 = FStar.UInt63
module U64 = FStar.UInt64
module I8  = FStar.Int8
module I16 = FStar.Int16
module I32 = FStar.Int32
module I63 = FStar.Int63
module I64 = FStar.Int64

let op_At_Percent = FStar.Int.op_At_Percent

/// Unsigned to unsigned

assume val uint8_to_uint64: a:U8.t -> Tot (b:U64.t{U64.v b = U8.v a})
assume val uint8_to_uint63: a:U8.t -> Tot (b:U63.t{U63.v b = U8.v a})
assume val uint8_to_uint32: a:U8.t -> Tot (b:U32.t{U32.v b = U8.v a})
assume val uint8_to_uint16: a:U8.t -> Tot (b:U16.t{U16.v b = U8.v a})

assume val uint16_to_uint64: a:U16.t -> Tot (b:U64.t{U64.v b = U16.v a})
assume val uint16_to_uint63: a:U16.t -> Tot (b:U63.t{U63.v b = U16.v a})
assume val uint16_to_uint32: a:U16.t -> Tot (b:U32.t{U32.v b = U16.v a})
assume val uint16_to_uint8 : a:U16.t -> Tot (b:U8.t{U8.v b = U16.v a % pow2 8})

assume val uint32_to_uint64: a:U32.t -> Tot (b:U64.t{U64.v b = U32.v a})
assume val uint32_to_uint63: a:U32.t -> Tot (b:U63.t{U63.v b = U32.v a})
assume val uint32_to_uint16: a:U32.t -> Tot (b:U16.t{U16.v b = U32.v a % pow2 16})
assume val uint32_to_uint8 : a:U32.t -> Tot (b:U8.t{U8.v b = U32.v a % pow2 8})

assume val uint63_to_uint64: a:U63.t -> Tot (b:U64.t{U64.v b = U63.v a})
assume val uint63_to_uint32: a:U63.t -> Tot (b:U32.t{U32.v b = U63.v a % pow2 32})
assume val uint63_to_uint16: a:U63.t -> Tot (b:U16.t{U16.v b = U63.v a % pow2 16})
assume val uint63_to_uint8 : a:U63.t -> Tot (b:U8.t{U8.v b = U63.v a % pow2 8})

assume val uint64_to_uint63: a:U64.t -> Tot (b:U63.t{U63.v b = U64.v a % pow2 63})
assume val uint64_to_uint32: a:U64.t -> Tot (b:U32.t{U32.v b = U64.v a % pow2 32})
assume val uint64_to_uint16: a:U64.t -> Tot (b:U16.t{U16.v b = U64.v a % pow2 16})
assume val uint64_to_uint8 : a:U64.t -> Tot (b:U8.t{U8.v b = U64.v a % pow2 8})

/// Signed to signed

assume val int8_to_int64: a:I8.t -> Tot (b:I64.t{I64.v b = I8.v a})
assume val int8_to_int63: a:I8.t -> Tot (b:I63.t{I63.v b = I8.v a})
assume val int8_to_int32: a:I8.t -> Tot (b:I32.t{I32.v b = I8.v a})
assume val int8_to_int16: a:I8.t -> Tot (b:I16.t{I16.v b = I8.v a})

assume val int16_to_int64: a:I16.t -> Tot (b:I64.t{I64.v b = I16.v a})
assume val int16_to_int63: a:I16.t -> Tot (b:I63.t{I63.v b = I16.v a})
assume val int16_to_int32: a:I16.t -> Tot (b:I32.t{I32.v b = I16.v a})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int16_to_int8 : a:I16.t -> Tot (b:I8.t {I8.v b  = (I16.v a @% pow2 8)})

assume val int32_to_int64: a:I32.t -> Tot (b:I64.t{I64.v b = I32.v a})
assume val int32_to_int63: a:I32.t -> Tot (b:I63.t{I63.v b = I32.v a})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int32_to_int16: a:I32.t -> Tot (b:I16.t{I16.v b = (I32.v a @% pow2 16)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int32_to_int8 : a:I32.t -> Tot (b:I8.t {I8.v b  = (I32.v a @% pow2 8)})

assume val int63_to_int64: a:I63.t -> Tot (b:I64.t{I64.v b = I63.v a})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int63_to_int32: a:I63.t -> Tot (b:I32.t{I32.v b = (I63.v a @% pow2 32)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int63_to_int16: a:I63.t -> Tot (b:I16.t{I16.v b = (I63.v a @% pow2 16)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int63_to_int8 : a:I63.t -> Tot (b:I8.t {I8.v b  = (I63.v a @% pow2 8)})

[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int64_to_int63: a:I64.t -> Tot (b:I63.t{I63.v b = (I64.v a @% pow2 63)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int64_to_int32: a:I64.t -> Tot (b:I32.t{I32.v b = (I64.v a @% pow2 32)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int64_to_int16: a:I64.t -> Tot (b:I16.t{I16.v b = (I64.v a @% pow2 16)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val int64_to_int8 : a:I64.t -> Tot (b:I8.t {I8.v b  = (I64.v a @% pow2 8)})

/// Unsigned to signed

assume val uint8_to_int64: a:U8.t -> Tot (b:I64.t{I64.v b = U8.v a})
assume val uint8_to_int63: a:U8.t -> Tot (b:I63.t{I63.v b = U8.v a})
assume val uint8_to_int32: a:U8.t -> Tot (b:I32.t{I32.v b = U8.v a})
assume val uint8_to_int16: a:U8.t -> Tot (b:I16.t{I16.v b = U8.v a})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint8_to_int8 : a:U8.t -> Tot (b:I8.t {I8.v b  = (U8.v a @% pow2 8)})

assume val uint16_to_int64: a:U16.t -> Tot (b:I64.t{I64.v b = U16.v a})
assume val uint16_to_int63: a:U16.t -> Tot (b:I63.t{I63.v b = U16.v a})
assume val uint16_to_int32: a:U16.t -> Tot (b:I32.t{I32.v b = U16.v a})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint16_to_int16: a:U16.t -> Tot (b:I16.t{I16.v b = (U16.v a @% pow2 16)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint16_to_int8 : a:U16.t -> Tot (b:I8.t {I8.v b  = (U16.v a @% pow2 8)})

assume val uint32_to_int64: a:U32.t -> Tot (b:I64.t{I64.v b = U32.v a})
assume val uint32_to_int63: a:U32.t -> Tot (b:I63.t{I63.v b = U32.v a})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint32_to_int32: a:U32.t -> Tot (b:I32.t{I32.v b = (U32.v a @% pow2 32)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint32_to_int16: a:U32.t -> Tot (b:I16.t{I16.v b = (U32.v a @% pow2 16)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint32_to_int8 : a:U32.t -> Tot (b:I8.t {I8.v b  = (U32.v a @% pow2 8)})

assume val uint63_to_int64: a:U63.t -> Tot (b:I64.t{I64.v b = U63.v a})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint63_to_int63: a:U63.t -> Tot (b:I63.t{I63.v b = (U63.v a @% pow2 63)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint63_to_int32: a:U63.t -> Tot (b:I32.t{I32.v b = (U63.v a @% pow2 32)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint63_to_int16: a:U63.t -> Tot (b:I16.t{I16.v b = (U63.v a @% pow2 16)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint63_to_int8 : a:U63.t -> Tot (b:I8.t {I8.v b  = (U63.v a @% pow2 8)})

[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint64_to_int64: a:U64.t -> Tot (b:I64.t{I64.v b = (U64.v a @% pow2 64)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint64_to_int63: a:U64.t -> Tot (b:I63.t{I63.v b = (U64.v a @% pow2 63)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint64_to_int32: a:U64.t -> Tot (b:I32.t{I32.v b = (U64.v a @% pow2 32)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint64_to_int16: a:U64.t -> Tot (b:I16.t{I16.v b = (U64.v a @% pow2 16)})
[@(deprecated "with care; in C the result is implementation-defined when not representable")]
assume val uint64_to_int8 : a:U64.t -> Tot (b:I8.t {I8.v b  = (U64.v a @% pow2 8)})

/// Signed to unsigned

assume val int8_to_uint64: a:I8.t -> Tot (b:U64.t{U64.v b = I8.v a % pow2 64})
assume val int8_to_uint63: a:I8.t -> Tot (b:U63.t{U63.v b = I8.v a % pow2 63})
assume val int8_to_uint32: a:I8.t -> Tot (b:U32.t{U32.v b = I8.v a % pow2 32})
assume val int8_to_uint16: a:I8.t -> Tot (b:U16.t{U16.v b = I8.v a % pow2 16})
assume val int8_to_uint8 : a:I8.t -> Tot (b:U8.t {U8.v b  = I8.v a % pow2 8})

assume val int16_to_uint64: a:I16.t -> Tot (b:U64.t{U64.v b = I16.v a % pow2 64})
assume val int16_to_uint63: a:I16.t -> Tot (b:U63.t{U63.v b = I16.v a % pow2 63})
assume val int16_to_uint32: a:I16.t -> Tot (b:U32.t{U32.v b = I16.v a % pow2 32})
assume val int16_to_uint16: a:I16.t -> Tot (b:U16.t{U16.v b = I16.v a % pow2 16})
assume val int16_to_uint8 : a:I16.t -> Tot (b:U8.t {U8.v b  = I16.v a % pow2 8})

assume val int32_to_uint64: a:I32.t -> Tot (b:U64.t{U64.v b = I32.v a % pow2 64})
assume val int32_to_uint63: a:I32.t -> Tot (b:U63.t{U63.v b = I32.v a % pow2 63})
assume val int32_to_uint32: a:I32.t -> Tot (b:U32.t{U32.v b = I32.v a % pow2 32})
assume val int32_to_uint16: a:I32.t -> Tot (b:U16.t{U16.v b = I32.v a % pow2 16})
assume val int32_to_uint8 : a:I32.t -> Tot (b:U8.t {U8.v b  = I32.v a % pow2 8})

assume val int63_to_uint64: a:I63.t -> Tot (b:U64.t{U64.v b = I63.v a % pow2 64})
assume val int63_to_uint63: a:I63.t -> Tot (b:U63.t{U63.v b = I63.v a % pow2 63})
assume val int63_to_uint32: a:I63.t -> Tot (b:U32.t{U32.v b = I63.v a % pow2 32})
assume val int63_to_uint16: a:I63.t -> Tot (b:U16.t{U16.v b = I63.v a % pow2 16})
assume val int63_to_uint8 : a:I63.t -> Tot (b:U8.t {U8.v b  = I63.v a % pow2 8})

assume val int64_to_uint64: a:I64.t -> Tot (b:U64.t{U64.v b = I64.v a % pow2 64})
assume val int64_to_uint63: a:I64.t -> Tot (b:U63.t{U63.v b = I64.v a % pow2 63})
assume val int64_to_uint32: a:I64.t -> Tot (b:U32.t{U32.v b = I64.v a % pow2 32})
assume val int64_to_uint16: a:I64.t -> Tot (b:U16.t{U16.v b = I64.v a % pow2 16})
assume val int64_to_uint8 : a:I64.t -> Tot (b:U8.t {U8.v b  = I64.v a % pow2 8})
