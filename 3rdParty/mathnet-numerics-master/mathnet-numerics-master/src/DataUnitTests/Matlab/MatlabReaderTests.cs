// <copyright file="MatlabReaderTests.cs" company="Math.NET">
// Math.NET Numerics, part of the Math.NET Project
// http://numerics.mathdotnet.com
// http://github.com/mathnet/mathnet-numerics
// http://mathnetnumerics.codeplex.com
// Copyright (c) 2009-2010 Math.NET
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
// </copyright>

using System.Numerics;
using MathNet.Numerics.Data.Matlab;
using NUnit.Framework;

namespace MathNet.Numerics.Data.UnitTests.Matlab
{
    /// <summary>
    /// Matlab matrix reader test.
    /// </summary>
    [TestFixture]
    public class MatlabReaderTests
    {
        /// <summary>
        /// Can read all matrices.
        /// </summary>
        [Test]
        public void CanReadAllMatrices()
        {
            var matrices = MatlabReader.ReadAll<double>("./data/Matlab/collection.mat");
            Assert.AreEqual(30, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Double.DenseMatrix), matrix.Value.GetType());
            }
        }

        /// <summary>
        /// Can read first matrix.
        /// </summary>
        [Test]
        public void CanReadFirstMatrix()
        {
            var matrix = MatlabReader.Read<double>("./data/Matlab/A.mat");
            Assert.AreEqual(100, matrix.RowCount);
            Assert.AreEqual(100, matrix.ColumnCount);
            Assert.AreEqual(typeof (LinearAlgebra.Double.DenseMatrix), matrix.GetType());
            AssertHelpers.AlmostEqual(100.108979553704, matrix.FrobeniusNorm(), 5);
        }

        /// <summary>
        /// Can read named matrices.
        /// </summary>
        [Test]
        public void CanReadNamedMatrices()
        {
            var matrices = MatlabReader.ReadAll<double>("./data/Matlab/collection.mat", "Ad", "Au64");
            Assert.AreEqual(2, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Double.DenseMatrix), matrix.Value.GetType());
            }
        }

        /// <summary>
        /// Can read named matrix.
        /// </summary>
        [Test]
        public void CanReadNamedMatrix()
        {
            var matrices = MatlabReader.ReadAll<double>("./data/Matlab/collection.mat", "Ad");
            Assert.AreEqual(1, matrices.Count);
            var ad = matrices["Ad"];
            Assert.AreEqual(100, ad.RowCount);
            Assert.AreEqual(100, ad.ColumnCount);
            AssertHelpers.AlmostEqual(100.431635988639, ad.FrobeniusNorm(), 5);
            Assert.AreEqual(typeof (LinearAlgebra.Double.DenseMatrix), ad.GetType());
        }

        /// <summary>
        /// Can read named sparse matrix.
        /// </summary>
        [Test]
        public void CanReadNamedSparseMatrix()
        {
            var matrix = MatlabReader.Read<double>("./data/Matlab/sparse-small.mat", "S");
            Assert.AreEqual(100, matrix.RowCount);
            Assert.AreEqual(100, matrix.ColumnCount);
            Assert.AreEqual(typeof (LinearAlgebra.Double.SparseMatrix), matrix.GetType());
            AssertHelpers.AlmostEqual(17.6385090630805, matrix.FrobeniusNorm(), 12);
        }

        /// <summary>
        /// Can read all complex matrices.
        /// </summary>
        [Test]
        public void CanReadComplexAllMatrices()
        {
            var matrices = MatlabReader.ReadAll<Complex>("./data/Matlab/complex.mat");
            Assert.AreEqual(3, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Complex.DenseMatrix), matrix.Value.GetType());
            }

            var a = matrices["a"];

            Assert.AreEqual(100, a.RowCount);
            Assert.AreEqual(100, a.ColumnCount);
            AssertHelpers.AlmostEqual(27.232498979698409, a.L2Norm(), 13);
        }

        /// <summary>
        /// Can read sparse complex matrices.
        /// </summary>
        [Test]
        public void CanReadSparseComplexAllMatrices()
        {
            var matrices = MatlabReader.ReadAll<Complex>("./data/Matlab/sparse_complex.mat");
            Assert.AreEqual(3, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Complex.SparseMatrix), matrix.Value.GetType());
            }

            var a = matrices["sa"];

            Assert.AreEqual(100, a.RowCount);
            Assert.AreEqual(100, a.ColumnCount);
            AssertHelpers.AlmostEqual(13.223654390985379, a.L2Norm(), 13);
        }

        /// <summary>
        /// Can read non-complex matrices.
        /// </summary>
        [Test]
        public void CanReadNonComplexAllMatrices()
        {
            var matrices = MatlabReader.ReadAll<Complex>("./data/Matlab/collection.mat");
            Assert.AreEqual(30, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Complex.DenseMatrix), matrix.Value.GetType());
            }
        }

        /// <summary>
        /// Can read non-complex first matrix.
        /// </summary>
        [Test]
        public void CanReadNonComplexFirstMatrix()
        {
            var matrix = MatlabReader.Read<Complex>("./data/Matlab/A.mat");
            Assert.AreEqual(100, matrix.RowCount);
            Assert.AreEqual(100, matrix.ColumnCount);
            Assert.AreEqual(typeof (LinearAlgebra.Complex.DenseMatrix), matrix.GetType());
            AssertHelpers.AlmostEqual(100.108979553704, matrix.FrobeniusNorm(), 13);
        }

        /// <summary>
        /// Can read non-complex named matrices.
        /// </summary>
        [Test]
        public void CanReadNonComplexNamedMatrices()
        {
            var matrices = MatlabReader.ReadAll<Complex>("./data/Matlab/collection.mat", "Ad", "Au64");
            Assert.AreEqual(2, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Complex.DenseMatrix), matrix.Value.GetType());
            }
        }

        /// <summary>
        /// Can read non-complex named matrix.
        /// </summary>
        [Test]
        public void CanReadNonComplexNamedMatrix()
        {
            var matrices = MatlabReader.ReadAll<Complex>("./data/Matlab/collection.mat", "Ad");
            Assert.AreEqual(1, matrices.Count);
            var ad = matrices["Ad"];
            Assert.AreEqual(100, ad.RowCount);
            Assert.AreEqual(100, ad.ColumnCount);
            AssertHelpers.AlmostEqual(100.431635988639, ad.FrobeniusNorm(), 13);
            Assert.AreEqual(typeof (LinearAlgebra.Complex.DenseMatrix), ad.GetType());
        }

        /// <summary>
        /// Can read non-complex named sparse matrix.
        /// </summary>
        [Test]
        public void CanReadNonComplexNamedSparseMatrix()
        {
            var matrix = MatlabReader.Read<Complex>("./data/Matlab/sparse-small.mat", "S");
            Assert.AreEqual(100, matrix.RowCount);
            Assert.AreEqual(100, matrix.ColumnCount);
            Assert.AreEqual(typeof (LinearAlgebra.Complex.SparseMatrix), matrix.GetType());
            AssertHelpers.AlmostEqual(17.6385090630805, matrix.FrobeniusNorm(), 12);
        }

        /// <summary>
        /// Can read all complex matrices.
        /// </summary>
        [Test]
        public void CanReadComplex32AllMatrices()
        {
            var matrices = MatlabReader.ReadAll<Complex32>("./data/Matlab/complex.mat");
            Assert.AreEqual(3, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Complex32.DenseMatrix), matrix.Value.GetType());
            }

            var a = matrices["a"];

            Assert.AreEqual(100, a.RowCount);
            Assert.AreEqual(100, a.ColumnCount);
            AssertHelpers.AlmostEqual(27.232498979698409, a.L2Norm(), 5);
        }

        /// <summary>
        /// Can read sparse complex matrices.
        /// </summary>
        [Test]
        public void CanReadSparseComplex32AllMatrices()
        {
            var matrices = MatlabReader.ReadAll<Complex32>("./data/Matlab/sparse_complex.mat");
            Assert.AreEqual(3, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Complex32.SparseMatrix), matrix.Value.GetType());
            }

            var a = matrices["sa"];

            Assert.AreEqual(100, a.RowCount);
            Assert.AreEqual(100, a.ColumnCount);
            AssertHelpers.AlmostEqual(13.223654390985379, a.L2Norm(), 5);
        }

        /// <summary>
        /// Can read non-complex matrices.
        /// </summary>
        [Test]
        public void CanReadNonComplex32AllMatrices()
        {
            var matrices = MatlabReader.ReadAll<Complex32>("./data/Matlab/collection.mat");
            Assert.AreEqual(30, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Complex32.DenseMatrix), matrix.Value.GetType());
            }
        }

        /// <summary>
        /// Can read non-complex first matrix.
        /// </summary>
        [Test]
        public void CanReadNonComplex32FirstMatrix()
        {
            var matrix = MatlabReader.Read<Complex32>("./data/Matlab/A.mat");
            Assert.AreEqual(100, matrix.RowCount);
            Assert.AreEqual(100, matrix.ColumnCount);
            Assert.AreEqual(typeof (LinearAlgebra.Complex32.DenseMatrix), matrix.GetType());
            AssertHelpers.AlmostEqual(100.108979553704, matrix.FrobeniusNorm(), 6);
        }

        /// <summary>
        /// Can read non-complex named matrices.
        /// </summary>
        [Test]
        public void CanReadNonComplex32NamedMatrices()
        {
            var matrices = MatlabReader.ReadAll<Complex32>("./data/Matlab/collection.mat", "Ad", "Au64");
            Assert.AreEqual(2, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Complex32.DenseMatrix), matrix.Value.GetType());
            }
        }

        /// <summary>
        /// Can read non-complex named matrix.
        /// </summary>
        [Test]
        public void CanReadNonComplex32NamedMatrix()
        {
            var matrices = MatlabReader.ReadAll<Complex32>("./data/Matlab/collection.mat", "Ad");
            Assert.AreEqual(1, matrices.Count);
            var ad = matrices["Ad"];
            Assert.AreEqual(100, ad.RowCount);
            Assert.AreEqual(100, ad.ColumnCount);
            AssertHelpers.AlmostEqual(100.431635988639, ad.FrobeniusNorm(), 6);
            Assert.AreEqual(typeof (LinearAlgebra.Complex32.DenseMatrix), ad.GetType());
        }

        /// <summary>
        /// Can read non-complex named sparse matrix.
        /// </summary>
        [Test]
        public void CanReadNonComplex32NamedSparseMatrix()
        {
            var matrix = MatlabReader.Read<Complex32>("./data/Matlab/sparse-small.mat", "S");
            Assert.AreEqual(100, matrix.RowCount);
            Assert.AreEqual(100, matrix.ColumnCount);
            Assert.AreEqual(typeof (LinearAlgebra.Complex32.SparseMatrix), matrix.GetType());
            AssertHelpers.AlmostEqual(17.6385090630805, matrix.FrobeniusNorm(), 6);
        }

        /// <summary>
        /// Can read all matrices.
        /// </summary>
        [Test]
        public void CanReadFloatAllMatrices()
        {
            var matrices = MatlabReader.ReadAll<float>("./data/Matlab/collection.mat");
            Assert.AreEqual(30, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Single.DenseMatrix), matrix.Value.GetType());
            }
        }

        /// <summary>
        /// Can read first matrix.
        /// </summary>
        [Test]
        public void CanReadFloatFirstMatrix()
        {
            var matrix = MatlabReader.Read<float>("./data/Matlab/A.mat");
            Assert.AreEqual(100, matrix.RowCount);
            Assert.AreEqual(100, matrix.ColumnCount);
            Assert.AreEqual(typeof (LinearAlgebra.Single.DenseMatrix), matrix.GetType());
            AssertHelpers.AlmostEqual(100.108979553704f, matrix.FrobeniusNorm(), 6);
        }

        /// <summary>
        /// Can read named matrices.
        /// </summary>
        [Test]
        public void CanReadFloatNamedMatrices()
        {
            var matrices = MatlabReader.ReadAll<float>("./data/Matlab/collection.mat", "Ad", "Au64");
            Assert.AreEqual(2, matrices.Count);
            foreach (var matrix in matrices)
            {
                Assert.AreEqual(typeof (LinearAlgebra.Single.DenseMatrix), matrix.Value.GetType());
            }
        }

        /// <summary>
        /// Can read named matrix.
        /// </summary>
        [Test]
        public void CanReadFloatNamedMatrix()
        {
            var matrices = MatlabReader.ReadAll<float>("./data/Matlab/collection.mat", "Ad");
            Assert.AreEqual(1, matrices.Count);
            var ad = matrices["Ad"];
            Assert.AreEqual(100, ad.RowCount);
            Assert.AreEqual(100, ad.ColumnCount);
            AssertHelpers.AlmostEqual(100.431635988639f, ad.FrobeniusNorm(), 6);
            Assert.AreEqual(typeof (LinearAlgebra.Single.DenseMatrix), ad.GetType());
        }

        /// <summary>
        /// Can read named sparse matrix.
        /// </summary>
        [Test]
        public void CanReadFloatNamedSparseMatrix()
        {
            var matrix = MatlabReader.Read<float>("./data/Matlab/sparse-small.mat", "S");
            Assert.AreEqual(100, matrix.RowCount);
            Assert.AreEqual(100, matrix.ColumnCount);
            Assert.AreEqual(typeof (LinearAlgebra.Single.SparseMatrix), matrix.GetType());
            AssertHelpers.AlmostEqual(17.6385090630805f, matrix.FrobeniusNorm(), 6);
        }
    }
}
