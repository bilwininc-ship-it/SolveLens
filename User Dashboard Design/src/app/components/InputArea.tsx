import { useState, useRef } from 'react';
import { motion } from 'motion/react';
import { Mic, Send } from 'lucide-react';

interface InputAreaProps {
  onSend: (message: string) => void;
  disabled?: boolean;
}

export function InputArea({ onSend, disabled }: InputAreaProps) {
  const [message, setMessage] = useState('');
  const [isFocused, setIsFocused] = useState(false);
  const inputRef = useRef<HTMLTextAreaElement>(null);

  const handleSubmit = () => {
    if (message.trim() && !disabled) {
      onSend(message.trim());
      setMessage('');
      if (inputRef.current) {
        inputRef.current.style.height = 'auto';
      }
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  const handleInput = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setMessage(e.target.value);
    
    // Auto-resize textarea
    e.target.style.height = 'auto';
    e.target.style.height = `${Math.min(e.target.scrollHeight, 200)}px`;
  };

  return (
    <div 
      className="fixed bottom-0 left-0 right-0 z-10 flex justify-center pb-8 pt-4"
      style={{
        background: 'linear-gradient(to top, #F9F9F7 80%, transparent)'
      }}
    >
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-4xl mx-auto px-8"
      >
        <div
          className="relative flex items-end gap-3 px-6 py-4 rounded-2xl transition-all duration-300"
          style={{
            background: isFocused 
              ? 'rgba(255, 255, 255, 0.95)'
              : 'rgba(255, 255, 255, 0.7)',
            backdropFilter: 'blur(12px)',
            border: isFocused 
              ? '1px solid rgba(0, 240, 255, 0.3)'
              : '1px solid rgba(10, 25, 47, 0.08)',
            boxShadow: isFocused
              ? '0 8px 32px rgba(10, 25, 47, 0.12), 0 0 20px rgba(0, 240, 255, 0.1)'
              : '0 4px 16px rgba(10, 25, 47, 0.06)',
            opacity: disabled ? 0.5 : 1,
            pointerEvents: disabled ? 'none' : 'auto'
          }}
        >
          {/* Voice Button */}
          <button
            className="flex items-center justify-center w-10 h-10 rounded-lg transition-all duration-200 flex-shrink-0"
            style={{
              background: 'rgba(10, 25, 47, 0.05)',
              color: '#0A192F'
            }}
            title="Voice input"
            disabled={disabled}
          >
            <Mic className="w-5 h-5" style={{ strokeWidth: 1.5 }} />
          </button>

          {/* Text Input */}
          <textarea
            ref={inputRef}
            value={message}
            onChange={handleInput}
            onKeyDown={handleKeyDown}
            onFocus={() => setIsFocused(true)}
            onBlur={() => setIsFocused(false)}
            placeholder="Pose your inquiry..."
            disabled={disabled}
            rows={1}
            className="flex-1 bg-transparent border-none outline-none resize-none"
            style={{
              color: '#0A192F',
              fontFamily: 'var(--font-family-body)',
              fontSize: '1rem',
              lineHeight: '1.5',
              maxHeight: '200px',
              minHeight: '24px'
            }}
          />

          {/* Submit Button */}
          <motion.button
            onClick={handleSubmit}
            disabled={!message.trim() || disabled}
            whileHover={message.trim() && !disabled ? { scale: 1.05 } : {}}
            whileTap={message.trim() && !disabled ? { scale: 0.95 } : {}}
            className="flex items-center justify-center w-10 h-10 rounded-lg transition-all duration-200 flex-shrink-0"
            style={{
              background: message.trim() && !disabled
                ? 'linear-gradient(135deg, #0A192F 0%, #1A2F4F 100%)'
                : 'rgba(10, 25, 47, 0.05)',
              color: message.trim() && !disabled ? '#00F0FF' : '#0A192F',
              opacity: message.trim() && !disabled ? 1 : 0.4
            }}
            title="Send message"
          >
            <Send className="w-5 h-5" style={{ strokeWidth: 1.5 }} />
          </motion.button>
        </div>

        {/* Helper text */}
        <p
          className="text-center mt-3 text-xs opacity-40"
          style={{
            color: '#0A192F',
            fontFamily: 'var(--font-family-body)'
          }}
        >
          Press Enter to send, Shift+Enter for new line
        </p>
      </motion.div>
    </div>
  );
}
