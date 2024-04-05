import matplotlib.pyplot as plot
import numpy as np
from scipy.fftpack import fft, fftshift

fc = 2000    #carrier frequency (Hz)
Ac = 1    #carrier Magnitude
fm = 250    #message frequency (Hz)
Am = 0.1    #message magnitude
k = 4    #modulation parameter

# generate single tone message signal

t = np.arange(0, 0.02, 1/10000)    #time with sampling at 10KHz
mt = Am * np.cos(2*np.pi*fm*t)    #message signal

# Phase modulation

sp = Ac * np.cos(2*np.pi*fc*t + 2*np.pi*k*mt)    #PM

# Frequency modulation

dmt = Am * np.sin(2*np.pi*fm*t);    #integration
sf = Ac * np.cos(2*np.pi*fc*t + 2*np.pi*k*dmt);    #FM

# Plot the signal

fig1, axs = plot.subplots(3, constrained_layout=True)
#plot 1:
axs[0].set_title("message m(t)")
axs[0].grid()
axs[0].plot(t, mt, color = 'blue')
axs[0].set_xlim([0, 0.02])
#plot 2:
axs[1].set_title("FM s(t)")
axs[1].grid()
axs[1].plot(t, sf, color = 'red')
axs[1].set_xlim([0, 0.02])
#plot 3: 
axs[2].set_title("PM s(t)")
axs[2].grid()
axs[2].plot(t, sp, color = 'black')
axs[2].set_xlim([0, 0.02])

# spectrum

Pm=abs(fftshift(fft(mt)))    #spectrum of message
Pp=abs(fftshift(fft(sp)))    #spectrum of PM signal
Pf=abs(fftshift(fft(sf)))    #spectrum of FM signal
w=((np.arange(len(t)))/len(t)-0.5)*10000

# plot the spectrums

fig2, axs = plot.subplots(3, constrained_layout=True)
#plot 1: 
axs[0].set_title("message spectrum M(f)")
axs[0].grid()
axs[0].plot(w, Pm, color = 'blue')
axs[0].set_xlim([-3000, 3000])
#plot 2:
axs[1].set_title("FM S(f)")
axs[1].grid()
axs[1].plot(w, Pp, color = 'red')
axs[1].set_xlim([-3000, 3000])
#plot 3: 
axs[2].set_title("PM S(f)")
axs[2].grid()
axs[2].plot(w, Pf, color = 'black')
axs[2].set_xlim([-3000, 3000])
