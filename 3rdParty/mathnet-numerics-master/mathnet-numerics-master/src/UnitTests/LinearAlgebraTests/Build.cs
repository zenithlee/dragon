﻿// <copyright file="Build.cs" company="Math.NET">
// Math.NET Numerics, part of the Math.NET Project
// http://numerics.mathdotnet.com
// http://github.com/mathnet/mathnet-numerics
// http://mathnetnumerics.codeplex.com
//
// Copyright (c) 2009-2014 Math.NET
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
// </copyright>

using System;
using System.Collections.Generic;
using MathNet.Numerics.LinearAlgebra.Storage;

namespace MathNet.Numerics.UnitTests.LinearAlgebraTests
{
    public enum VectorStorageType
    {
        DenseVector = 1,
        SparseVector = 2
    }

    public static class Build
    {
        public static VectorStorage<T> VectorStorage<T>(VectorStorageType type, IEnumerable<T> data)
            where T : struct, IEquatable<T>, IFormattable
        {
            switch (type)
            {
                case VectorStorageType.DenseVector:
                    return DenseVectorStorage<T>.OfEnumerable(data);
                case VectorStorageType.SparseVector:
                    return SparseVectorStorage<T>.OfEnumerable(data);
                default:
                    throw new NotSupportedException();
            }
        }

        public static VectorStorage<T> VectorStorage<T>(VectorStorageType type, int length)
            where T : struct, IEquatable<T>, IFormattable
        {
            switch (type)
            {
                case VectorStorageType.DenseVector:
                    return new DenseVectorStorage<T>(length);
                case VectorStorageType.SparseVector:
                    return new SparseVectorStorage<T>(length);
                default:
                    throw new NotSupportedException();
            }
        }
    }
}
