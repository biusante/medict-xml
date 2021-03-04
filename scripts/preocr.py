# -*- coding: utf-8 -*-
from PIL import Image
import os
import argparse
import cv2
import numpy as np
from matplotlib import pyplot as plt
from skimage.color import rgb2gray
from skimage.filters import (threshold_yen, threshold_otsu, threshold_niblack, threshold_sauvola, threshold_local)
from skimage.exposure import rescale_intensity
from skimage.io import imread, imsave
from deskew import determine_skew
from skimage.transform import rotate


def main():
  parser = argparse.ArgumentParser(description='Améliorer des images de page pour l’ocr')
  parser.add_argument('images', metavar='image', nargs='+', help='Un ou plusieurs fichiers image')
  args = parser.parse_args()
  for src in args.images:
    beautify(src)

def beautify(src):
  """
  optimize 
  """
  dstname, _ = os.path.splitext(os.path.basename(src))
  dst = os.path.join(os.path.dirname(src), "out")
  os.makedirs(dst, exist_ok=True)
  dst =  os.path.join(dst, dstname + '.png')
  dpi = fdpi(src)
  print(dpi)
  fx = 2;
  if (dpi < 250):
    fx = 3;
  if (dpi > 500):
    fx = 1;
  img = imread(src)
  img = cv2.resize(img, None, fx=fx, fy=fx, interpolation=cv2.INTER_CUBIC)
  thresh = threshold_yen(img)
  # thresh = threshold_otsu(img)
  img = rescale_intensity(img, (0, thresh), (0, 255))
  
  
  
  img = cv2.GaussianBlur(img, (9,9), 0)
  kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3,3))
  img = cv2.erode(img, kernel, iterations=2)
  kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3,3))
  img = cv2.dilate(img, kernel, iterations=1)
  thresh = threshold_yen(img)
  img = rescale_intensity(img, (0, thresh), (0, 255))
  
  img = img.astype(np.uint8)
  img = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_AREA)
  imsave(dst, img)
  return
  mask = np.zeros(img.shape, dtype=np.uint8)
  # img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
  img = cv2.GaussianBlur(img, (7,7), 0)
  img = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV,51,9)
  
  
  kernel = np.ones((5,5),np.uint8)
  img = cv.dilate(img, kernel, iterations = 1)
  img = cv.erode(img, kernel, iterations = 1)


  
  # img = cv.morphologyEx(img, cv.MORPH_OPEN, kernel)
  # deskew bad
  # angle = determine_skew(img)
  # print("angle: {0} \n".format(angle));
  # img = rotate(img, angle, resize=True) * 255
  # img = cv2.blur(img,(5,5))
  # img = cv2.GaussianBlur(img, (5, 5), 0)
  # img = cv2.medianBlur(img, 3)
  # img = cv2.bilateralFilter(img,9,75,75)
  
def fdpi(src):
  image_file = Image.open(src)
  if image_file.info.get('dpi'):
    x_dpi, y_dpi = image_file.info['dpi']
    if x_dpi != y_dpi:
      print('Inconsistent DPI image data')
      return None
    return x_dpi;
  else:
    return None

if __name__ == "__main__":main()
