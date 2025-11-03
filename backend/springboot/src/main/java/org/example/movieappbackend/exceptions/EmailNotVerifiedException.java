package org.example.movieappbackend.exceptions;

public class EmailNotVerifiedException extends RuntimeException {
    
    private String resourceName;
    private String fieldName;
    private Object fieldValue;
    
    public EmailNotVerifiedException(String resourceName, String fieldName, Object fieldValue) {
        super(String.format("%s not verified for %s: %s", resourceName, fieldName, fieldValue));
        this.resourceName = resourceName;
        this.fieldName = fieldName;
        this.fieldValue = fieldValue;
    }
    
    public EmailNotVerifiedException(String message) {
        super(message);
    }
    
    public String getResourceName() {
        return resourceName;
    }
    
    public String getFieldName() {
        return fieldName;
    }
    
    public Object getFieldValue() {
        return fieldValue;
    }
}