﻿// <copyright file="DelimitedReader.cs" company="Math.NET">
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
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Text.RegularExpressions;
using MathNet.Numerics.LinearAlgebra;

namespace MathNet.Numerics.Data.Text
{
    /// <summary>
    /// Creates a <see cref="Matrix{T}"/> from a delimited text file. If the user does not
    /// specify a delimiter, then any whitespace is used.
    /// </summary>
    public static class DelimitedReader
    {
        /// <summary>
        /// The base regular expression.
        /// </summary>
        const string RegexTemplate = "\\([^\\)]*\\)|'[^']*'|\"[^\"]*\"|[^{0}]*";

        /// <summary>
        /// Cached compiled regular expressions for various delimiters, as needed.
        /// </summary>
        static readonly ConcurrentDictionary<string, Regex> RegexCache = new ConcurrentDictionary<string, Regex>();

        /// <summary>
        /// Reads a <see cref="Matrix{TDataType}"/> from the given <see cref="TextReader"/>.
        /// </summary>
        /// <param name="reader">The <see cref="TextReader"/> to read the matrix from.</param>
        /// <param name="sparse">Whether the returned matrix should be constructed as sparse (true) or dense (false). Default: false.</param>
        /// <param name="delimiter">Number delimiter between numbers of the same line. Supports Regex groups. Default: "\s" (white space).</param>
        /// <param name="hasHeaders">Whether the first row contains column headers or not. Default: false.</param>
        /// <param name="formatProvider">The culture to use. Default: null.</param>
        /// <returns>A matrix containing the data from the <see cref="TextReader"/>.</returns>
        /// <typeparam name="T">The data type of the Matrix. It can be either: double, float, Complex, or Complex32.</typeparam>
        public static Matrix<T> Read<T>(TextReader reader, bool sparse = false, string delimiter = @"\s", bool hasHeaders = false, IFormatProvider formatProvider = null)
            where T : struct, IEquatable<T>, IFormattable
        {
            if (string.IsNullOrEmpty(delimiter))
            {
                delimiter = @"\s";
            }

            var regex = RegexCache.GetOrAdd(delimiter, d => new Regex(string.Format(RegexTemplate, d), RegexOptions.Compiled));

            var data = new List<string[]>();

            // max is used to supports files like:
            // 1,2
            // 3,4,5,6
            // 7
            // this creates a 3x4 matrix:
            // 1, 2, 0 ,0
            // 3, 4, 5, 6
            // 7, 0, 0, 0
            var max = -1;

            var line = reader.ReadLine();
            if (hasHeaders)
            {
                line = reader.ReadLine();
            }

            while (line != null)
            {
                line = line.Trim();
                if (line.Length > 0)
                {
                    var matches = regex.Matches(line);
                    var row = (from Match match in matches where match.Length > 0 select match.Value).ToArray();
                    max = Math.Max(max, row.Length);
                    data.Add(row);
                }

                line = reader.ReadLine();
            }

            var parse = CreateParser<T>(formatProvider);
            var matrix = sparse ? Matrix<T>.Build.Sparse(data.Count, max) : Matrix<T>.Build.Dense(data.Count, max);
            var storage = matrix.Storage;

            for (var i = 0; i < data.Count; i++)
            {
                var row = data[i];
                for (var j = 0; j < row.Length; j++)
                {
                    // strip off quotes (TODO: can we replace this with trimming?)
                    var value = row[j].Replace("'", string.Empty).Replace("\"", string.Empty);
                    storage.At(i, j, parse(value));
                }
            }

            reader.Close();
            reader.Dispose();

            return matrix;
        }

        /// <summary>
        /// Reads a <see cref="Matrix{TDataType}"/> from the given file.
        /// </summary>
        /// <param name="filePath">The path and name of the file to read the matrix from.</param>
        /// <param name="sparse">Whether the returned matrix should be constructed as sparse (true) or dense (false). Default: false.</param>
        /// <param name="delimiter">Number delimiter between numbers of the same line. Supports Regex groups. Default: "\s" (white space).</param>
        /// <param name="hasHeaders">Whether the first row contains column headers or not. Default: false.</param>
        /// <param name="formatProvider">The culture to use. Default: null.</param>
        /// <returns>A matrix containing the data from the <see cref="TextReader"/>.</returns>
        /// <typeparam name="T">The data type of the Matrix. It can be either: double, float, Complex, or Complex32.</typeparam>
        public static Matrix<T> Read<T>(string filePath, bool sparse = false, string delimiter = @"\s", bool hasHeaders = false, IFormatProvider formatProvider = null)
            where T : struct, IEquatable<T>, IFormattable
        {
            using (var reader = new StreamReader(filePath))
            {
                return Read<T>(reader, sparse, delimiter, hasHeaders, formatProvider);
            }
        }

        /// <summary>
        /// Reads a <see cref="Matrix{TDataType}"/> from the given <see cref="Stream"/>.
        /// </summary>
        /// <param name="stream">The <see cref="Stream"/> to read the matrix from.</param>
        /// <param name="sparse">Whether the returned matrix should be constructed as sparse (true) or dense (false). Default: false.</param>
        /// <param name="delimiter">Number delimiter between numbers of the same line. Supports Regex groups. Default: "\s" (white space).</param>
        /// <param name="hasHeaders">Whether the first row contains column headers or not. Default: false.</param>
        /// <param name="formatProvider">The culture to use. Default: null.</param>
        /// <returns>A matrix containing the data from the <see cref="TextReader"/>.</returns>
        /// <typeparam name="T">The data type of the Matrix. It can be either: double, float, Complex, or Complex32.</typeparam>
        public static Matrix<T> Read<T>(Stream stream, bool sparse = false, string delimiter = @"\s", bool hasHeaders = false, IFormatProvider formatProvider = null)
            where T : struct, IEquatable<T>, IFormattable
        {
            using (var reader = new StreamReader(stream))
            {
                return Read<T>(reader, sparse, delimiter, hasHeaders, formatProvider);
            }
        }

        static Func<string, T> CreateParser<T>(IFormatProvider formatProvider)
        {
            if (typeof (T) == typeof (double))
            {
                return number => (T)(object)double.Parse(number, NumberStyles.Any, formatProvider);
            }

            if (typeof (T) == typeof (float))
            {
                return number => (T)(object)float.Parse(number, NumberStyles.Any, formatProvider);
            }

            if (typeof (T) == typeof (Complex))
            {
                return number => (T)(object)number.ToComplex(formatProvider);
            }

            if (typeof (T) == typeof (Complex32))
            {
                return number => (T)(object)number.ToComplex32(formatProvider);
            }

            throw new NotSupportedException();
        }
    }
}
