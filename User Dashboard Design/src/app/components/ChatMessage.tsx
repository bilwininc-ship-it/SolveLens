import { motion } from 'motion/react';

interface Message {
  id: string;
  type: 'user' | 'ai';
  content: string;
  timestamp: Date;
  hasCode?: boolean;
  hasMath?: boolean;
}

interface ChatMessageProps {
  message: Message;
  isLast: boolean;
}

export function ChatMessage({ message, isLast }: ChatMessageProps) {
  // Parse content for math/code blocks
  const renderContent = (content: string) => {
    // Check for LaTeX-style math blocks
    const mathBlockRegex = /\$\$([\s\S]*?)\$\$/g;
    const parts = [];
    let lastIndex = 0;
    let match;

    while ((match = mathBlockRegex.exec(content)) !== null) {
      // Add text before math block
      if (match.index > lastIndex) {
        parts.push({
          type: 'text',
          content: content.substring(lastIndex, match.index)
        });
      }
      
      // Add math block
      parts.push({
        type: 'math',
        content: match[1].trim()
      });
      
      lastIndex = match.index + match[0].length;
    }
    
    // Add remaining text
    if (lastIndex < content.length) {
      parts.push({
        type: 'text',
        content: content.substring(lastIndex)
      });
    }
    
    // If no math blocks found, return as single text block
    if (parts.length === 0) {
      parts.push({ type: 'text', content });
    }
    
    return parts;
  };

  const contentParts = renderContent(message.content);

  if (message.type === 'user') {
    return (
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, ease: "easeOut" }}
        className="mb-8"
      >
        <h3 
          className="text-xl leading-relaxed"
          style={{
            color: '#0A192F',
            fontFamily: 'var(--font-family-heading)',
            fontWeight: 600
          }}
        >
          Inquiry: {message.content}
        </h3>
      </motion.div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, ease: "easeOut" }}
      className={isLast ? 'mb-8' : 'mb-12'}
    >
      {contentParts.map((part, index) => {
        if (part.type === 'math') {
          return (
            <div
              key={index}
              className="my-6 p-4 rounded-lg overflow-x-auto"
              style={{
                background: 'rgba(10, 25, 47, 0.03)',
                borderLeft: '3px solid #00F0FF',
                fontFamily: 'Georgia, serif'
              }}
            >
              <pre 
                className="text-sm leading-relaxed whitespace-pre-wrap"
                style={{
                  color: '#0A192F',
                  margin: 0
                }}
              >
                {part.content}
              </pre>
            </div>
          );
        }
        
        return (
          <div key={index}>
            {part.content.split('\n\n').map((paragraph, pIndex) => (
              <p
                key={pIndex}
                className="mb-6 leading-[1.8] text-justify"
                style={{
                  color: '#0A192F',
                  fontFamily: 'var(--font-family-heading)',
                  fontSize: '1.0625rem',
                  lineHeight: '1.8'
                }}
              >
                {paragraph}
              </p>
            ))}
          </div>
        );
      })}
    </motion.div>
  );
}
