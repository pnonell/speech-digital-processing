# Speech digital processing

This project consisted in applying audio processing techniques to model and modify speech audio.

The project has two parts which both use a pre-recorded speech audio (audio_original.wav):

- 1st Part: modelat_mhe.m 

    Analysis of the pitch marks of the audio, splitting of the harmonic (audio_h.wav) and stochastic (audio_n.wav) parts and reconstructio0n of the audio (audio_hn.wav).

- 2n Part: modelat_mhet.m

    Analysis and splitting of the original audio to change its Time and Pitch with established factors (T_fact and F_fact). The script saves the modified audio at the end. On this repository there are 3 modified exported audios: 
    - T_fact = 2 and F_fact = 1 (audio_hn_T2.wav)
    - T_fact = 1 and F_fact = 0.4 (audio_hn_F04.wav)
    - T_fact = 0.7 and F_fact = 2.5 (audio_hn_T07F25) 

    
