#|
 This file is a part of harmony
 (c) 2017 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:cl-user)
(defpackage #:harmony-out123
  (:nicknames #:org.shirakumo.fraf.harmony.drains.out123)
  (:use #:cl #:harmony)
  (:export
   #:out123-drain))
(in-package #:org.shirakumo.fraf.harmony.drains.out123)

(defclass out123-drain (pack-drain)
  ((program-name :initform NIL :initarg :program-name :accessor program-name)
   (device :initform NIL :accessor device)))

(defmethod initialize-instance :after ((drain out123-drain) &key)
  (setf (cl-mixed-cffi:direct-segment-start (cl-mixed:handle drain)) (cffi:callback start))
  (setf (cl-mixed-cffi:direct-segment-end (cl-mixed:handle drain)) (cffi:callback end)))

(defmethod initialize-packed-audio ((drain out123-drain))
  (let ((out (cl-out123:make-output NIL :name (or (program-name drain)
                                                  (cl-out123:device-default-name "Harmony")))))
    (cl-out123:connect out)
    (cl-out123:start out :rate (samplerate (context drain))
                         :channels 2
                         :encoding :float)
    (setf (device drain) out)
    (multiple-value-bind (rate channels encoding) (cl-out123:playback-format out)
      (cl-out123:stop out)
      (cl-mixed:make-packed-audio
       NIL
       (* (buffersize (context drain))
          (cl-mixed:samplesize encoding)
          channels)
       encoding
       channels
       :alternating
       rate))))

(defmethod process ((drain out123-drain) samples)
  (let* ((pack (cl-mixed:packed-audio drain))
         (buffer (cl-mixed:data pack))
         (bytes (* samples
                   (cl-mixed:samplesize (cl-mixed:encoding pack))
                   (cl-mixed:channels pack))))
    (cl-out123:play-directly (device drain) buffer bytes)))

(defmethod paused-p ((drain out123-drain))
  (not (cl-out123:playing (device drain))))

(defmethod (setf paused-p) (value (drain out123-drain))
  (with-body-in-mixing-context ((context drain))
    (if value
        (cl-out123:pause (device drain))
        (cl-out123:resume (device drain)))))

(defmethod pause ((drain out123-drain))
  (with-body-in-mixing-context ((context drain))
    (cl-out123:pause (device drain))))

(defmethod resume ((drain out123-drain))
  (with-body-in-mixing-context ((context drain))
    (cl-out123:resume (device drain))))

(cffi:defcallback start :int ((segment :pointer))
  (cl-out123:start (device (cl-mixed:pointer->object segment)))
  1)

(cffi:defcallback end :int ((segment :pointer))
  (cl-out123:stop (device (cl-mixed:pointer->object segment)))
  1)
