import matplotlib.pyplot as plot
import numpy as np
from scipy.fftpack import fft, fftshift

fc=1000    #carrier frequency (Hz)
Ac=1    #magnitude
fm=200    #message frequency (Hz)
Am=0.5    #magnitude
kf=120    #frequency sensitivity
beta=kf*Am/fm    #modulation parameter

t = np.arange(0, 1, 1/10000)    #time with sampling at 10KHz
mt=Am*np.cos(2*np.pi*fm*t)    #message signal
sam=(Ac+mt)*np.cos(2*np.pi*fc*t)    #AM signal
sfm=Ac*np.cos(2*np.pi*fc*t+beta*np.sin(2*np.pi*fm*t))    #FM signal

# spectrum

w=(np.arange(0,len(t))/len(t)-0.5)*10000
Fam=abs(fftshift(fft(sam)))    #spectrum of AM signal
Ffm=abs(fftshift(fft(sfm)))    #spectrum of FM signal

# Plot the signal

fig1, axs = plot.subplots(2, 2, constrained_layout=True)
#plot 1:
axs[0, 0].set_title("AM signal")
axs[0, 0].grid()
axs[0, 0].plot(t, sam, color = 'blue')
axs[0, 0].set_xlim([0, 0.02])
#plot 2:
axs[0, 1].set_title("AM signal spectrum")
axs[0, 1].grid()
axs[0, 1].plot(w, Fam, color = 'red')
axs[0, 1].set_xlim([-2000, 2000])
#plot 3:
axs[1, 0].set_title("FM signal")
axs[1, 0].grid()
axs[1, 0].plot(t, sfm, color = 'blue')
axs[1, 0].set_xlim([0, 0.02])
#plot 4:
axs[1, 1].set_title("FM signal spectrum")
axs[1, 1].grid()
axs[1, 1].plot(w, Ffm, color = 'red')
axs[1, 1].set_xlim([-2000, 2000])
