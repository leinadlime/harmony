#|
 This file is a part of harmony
 (c) 2017 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.fraf.harmony)

(cffi:defcfun (memcpy "memcpy") :pointer
  (dest :pointer)
  (source :pointer)
  (num cl-mixed-cffi:size_t))

(cffi:defcfun (memset "memset") :pointer
  (dest :pointer)
  (source :int)
  (num cl-mixed-cffi:size_t))

(declaim (inline memclear))
(defun memclear (dest num)
  (memset dest 0 num))

(defun ease-linear (x)
  (declare (optimize speed))
  (declare (type single-float x))
  x)

(defun ease-cubic-in (x)
  (declare (optimize speed))
  (declare (type single-float x))
  (expt x 3))

(defun ease-cubic-out (x)
  (declare (optimize speed))
  (declare (type single-float x))
  (1+ (expt (1- x) 3)))

(defun ease-cubic-in-out (x)
  (declare (optimize speed))
  (declare (type single-float x))
  (if (< x 0.5)
      (/ (expt (* 2 x) 3) 2)
      (1+ (/ (expt (* 2 (1- x)) 3) 2))))
