import { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ArrowLeft, Camera, Zap, Image as ImageIcon, RotateCcw, Sparkles, Edit3, Send } from 'lucide-react';

interface DocumentScanScreenProps {
  onBack: () => void;
}

type ScanState = 'camera' | 'preview' | 'results';

export function DocumentScanScreen({ onBack }: DocumentScanScreenProps) {
  const [scanState, setScanState] = useState<ScanState>('camera');
  const [flashEnabled, setFlashEnabled] = useState(false);
  const [capturedImage, setCapturedImage] = useState<string | null>(null);
  const [ocrText, setOcrText] = useState('');
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleCapture = () => {
    // Simulate capture
    setScanState('preview');
    setCapturedImage('https://images.unsplash.com/photo-1456324504439-367cee3b3c32?w=800&q=80');
  };

  const handleGallery = () => {
    fileInputRef.current?.click();
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        setCapturedImage(event.target?.result as string);
        setScanState('preview');
      };
      reader.readAsDataURL(file);
    }
  };

  const handleRetake = () => {
    setScanState('camera');
    setCapturedImage(null);
    setOcrText('');
  };

  const handleOCRAnalyze = () => {
    setIsAnalyzing(true);
    setScanState('results');
    
    // Simulate OCR processing
    setTimeout(() => {
      setOcrText(`Dark Matter and Galaxy Rotation Curves

The discrepancy between the observed rotation curves of galaxies and those predicted by Newtonian dynamics provides compelling evidence for the existence of dark matter. 

In classical mechanics, we expect orbital velocities to decrease with distance from the galactic center according to:

v(r) ∝ r^(-1/2)

However, observations reveal that rotation curves remain remarkably flat at large radii, suggesting the presence of an extended dark matter halo.

Key Points:
• Flat rotation curves indicate M(r) ∝ r
• Implies density profile ρ(r) ∝ r^(-2)
• Consistent with NFW (Navarro-Frenk-White) profiles

This observational evidence, first noted by Vera Rubin and Kent Ford in the 1970s, remains one of the strongest indicators of dark matter's existence.`);
      setIsAnalyzing(false);
    }, 2000);
  };

  return (
    <div 
      className="fixed inset-0 flex flex-col"
      style={{ background: '#0A192F' }}
    >
      {/* Header */}
      <div 
        className="flex items-center justify-between px-6 py-4 z-30"
        style={{ 
          background: '#0A192F',
          borderBottom: '1px solid rgba(255, 255, 255, 0.1)'
        }}
      >
        <button
          onClick={onBack}
          className="flex items-center gap-2 opacity-60 hover:opacity-100 transition-opacity"
          style={{ 
            color: '#ffffff',
            fontFamily: 'var(--font-family-body)'
          }}
        >
          <ArrowLeft className="w-5 h-5" />
          <span>Back</span>
        </button>

        <h1
          className="text-xl"
          style={{
            color: '#ffffff',
            fontFamily: 'var(--font-family-heading)'
          }}
        >
          Document Scan
        </h1>

        <div className="w-20"></div>
      </div>

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileSelect}
        className="hidden"
      />

      {/* Main Content */}
      <div className="flex-1 relative overflow-hidden">
        <AnimatePresence mode="wait">
          {/* Camera View */}
          {scanState === 'camera' && (
            <motion.div
              key="camera"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 flex items-center justify-center"
            >
              {/* Simulated camera view */}
              <div className="relative w-full h-full flex items-center justify-center">
                <div
                  className="absolute inset-0"
                  style={{
                    background: 'linear-gradient(135deg, rgba(10, 25, 47, 0.9) 0%, rgba(0, 50, 80, 0.9) 100%)'
                  }}
                />
                
                {/* Document placement guide */}
                <div
                  className="relative w-[80%] max-w-md aspect-[3/4] rounded-2xl"
                  style={{
                    border: '2px dashed #00F0FF',
                    background: 'rgba(0, 240, 255, 0.05)'
                  }}
                >
                  <div className="absolute inset-0 flex items-center justify-center">
                    <p
                      className="text-center px-6"
                      style={{
                        color: '#00F0FF',
                        fontFamily: 'var(--font-family-body)',
                        opacity: 0.7
                      }}
                    >
                      Position document within frame
                    </p>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="absolute bottom-8 left-0 right-0 flex items-center justify-center gap-6 px-6">
                {/* Flash */}
                <motion.button
                  whileTap={{ scale: 0.9 }}
                  onClick={() => setFlashEnabled(!flashEnabled)}
                  className="flex items-center justify-center w-14 h-14 rounded-full"
                  style={{
                    background: flashEnabled ? '#00F0FF' : 'rgba(255, 255, 255, 0.2)',
                    border: '1px solid rgba(255, 255, 255, 0.3)'
                  }}
                >
                  <Zap 
                    className="w-6 h-6"
                    style={{ 
                      color: flashEnabled ? '#0A192F' : '#ffffff',
                      fill: flashEnabled ? '#0A192F' : 'none'
                    }}
                  />
                </motion.button>

                {/* Capture */}
                <motion.button
                  whileTap={{ scale: 0.9 }}
                  onClick={handleCapture}
                  className="flex items-center justify-center w-20 h-20 rounded-full"
                  style={{
                    background: '#00F0FF',
                    boxShadow: '0 0 30px rgba(0, 240, 255, 0.5)'
                  }}
                >
                  <Camera className="w-8 h-8" style={{ color: '#0A192F' }} />
                </motion.button>

                {/* Gallery */}
                <motion.button
                  whileTap={{ scale: 0.9 }}
                  onClick={handleGallery}
                  className="flex items-center justify-center w-14 h-14 rounded-full"
                  style={{
                    background: 'rgba(255, 255, 255, 0.2)',
                    border: '1px solid rgba(255, 255, 255, 0.3)'
                  }}
                >
                  <ImageIcon className="w-6 h-6" style={{ color: '#ffffff' }} />
                </motion.button>
              </div>
            </motion.div>
          )}

          {/* Preview View */}
          {scanState === 'preview' && capturedImage && (
            <motion.div
              key="preview"
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="absolute inset-0 flex flex-col"
              style={{ background: '#0A192F' }}
            >
              {/* Image Preview */}
              <div className="flex-1 flex items-center justify-center p-6">
                <img
                  src={capturedImage}
                  alt="Captured document"
                  className="max-w-full max-h-full rounded-xl"
                  style={{
                    boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)'
                  }}
                />
              </div>

              {/* Action Buttons */}
              <div className="flex gap-4 p-6">
                <motion.button
                  whileTap={{ scale: 0.95 }}
                  onClick={handleRetake}
                  className="flex-1 flex items-center justify-center gap-2 px-6 py-4 rounded-xl"
                  style={{
                    background: 'rgba(255, 255, 255, 0.1)',
                    border: '1px solid rgba(255, 255, 255, 0.2)',
                    color: '#ffffff',
                    fontFamily: 'var(--font-family-body)'
                  }}
                >
                  <RotateCcw className="w-5 h-5" />
                  Retake
                </motion.button>

                <motion.button
                  whileTap={{ scale: 0.95 }}
                  onClick={handleOCRAnalyze}
                  className="flex-1 flex items-center justify-center gap-2 px-6 py-4 rounded-xl"
                  style={{
                    background: 'linear-gradient(135deg, #00F0FF 0%, #00C0CC 100%)',
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-body)',
                    fontWeight: 600
                  }}
                >
                  <Sparkles className="w-5 h-5" />
                  OCR Analyze
                </motion.button>
              </div>
            </motion.div>
          )}

          {/* Results View */}
          {scanState === 'results' && (
            <motion.div
              key="results"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 flex flex-col"
              style={{ background: '#F9F9F7' }}
            >
              {isAnalyzing ? (
                <div className="flex-1 flex items-center justify-center">
                  <div className="text-center">
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                      className="w-16 h-16 mx-auto mb-4 rounded-full"
                      style={{
                        border: '3px solid rgba(0, 240, 255, 0.2)',
                        borderTopColor: '#00F0FF'
                      }}
                    />
                    <p
                      style={{
                        color: '#0A192F',
                        fontFamily: 'var(--font-family-body)'
                      }}
                    >
                      Analyzing document...
                    </p>
                  </div>
                </div>
              ) : (
                <>
                  {/* Extracted Text */}
                  <div className="flex-1 overflow-y-auto p-6 scrollbar-thin">
                    <div className="max-w-3xl mx-auto">
                      <h3
                        className="mb-6"
                        style={{
                          color: '#0A192F',
                          fontFamily: 'var(--font-family-heading)',
                          fontSize: '1.5rem'
                        }}
                      >
                        Extracted Text
                      </h3>
                      
                      <div
                        className="p-6 rounded-xl whitespace-pre-wrap leading-relaxed"
                        style={{
                          background: '#ffffff',
                          border: '1px solid rgba(10, 25, 47, 0.1)',
                          color: '#0A192F',
                          fontFamily: 'var(--font-family-body)',
                          lineHeight: '1.8'
                        }}
                      >
                        {ocrText}
                      </div>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="flex gap-4 p-6" style={{ borderTop: '1px solid rgba(10, 25, 47, 0.1)' }}>
                    <motion.button
                      whileTap={{ scale: 0.95 }}
                      onClick={handleRetake}
                      className="flex-1 flex items-center justify-center gap-2 px-6 py-4 rounded-xl"
                      style={{
                        background: 'rgba(10, 25, 47, 0.05)',
                        border: '1px solid rgba(10, 25, 47, 0.1)',
                        color: '#0A192F',
                        fontFamily: 'var(--font-family-body)'
                      }}
                    >
                      <RotateCcw className="w-5 h-5" />
                      Scan New
                    </motion.button>

                    <motion.button
                      whileTap={{ scale: 0.95 }}
                      className="flex-1 flex items-center justify-center gap-2 px-6 py-4 rounded-xl"
                      style={{
                        background: 'rgba(10, 25, 47, 0.05)',
                        border: '1px solid rgba(10, 25, 47, 0.1)',
                        color: '#0A192F',
                        fontFamily: 'var(--font-family-body)'
                      }}
                    >
                      <Edit3 className="w-5 h-5" />
                      Edit
                    </motion.button>

                    <motion.button
                      whileTap={{ scale: 0.95 }}
                      className="flex-1 flex items-center justify-center gap-2 px-6 py-4 rounded-xl"
                      style={{
                        background: 'linear-gradient(135deg, #0A192F 0%, #1A2F4F 100%)',
                        color: '#00F0FF',
                        fontFamily: 'var(--font-family-body)',
                        fontWeight: 600
                      }}
                    >
                      <Send className="w-5 h-5" />
                      Send to AI Chat
                    </motion.button>
                  </div>
                </>
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
