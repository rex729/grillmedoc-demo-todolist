const VALID_STATES = ['todo', 'in progress', 'done'];
const VALID_CATEGORIES = ['company', 'personal', 'other'];

/**
 * 嚴格驗證西元曆有效日期 (yyyy-mm-dd)，防呆無效日期（例如平年 2/29、4/31 等）
 */
function isValidDate(dateStr) {
  if (typeof dateStr !== 'string') return false;
  const match = dateStr.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!match) return false;

  const year = parseInt(match[1], 10);
  const month = parseInt(match[2], 10);
  const day = parseInt(match[3], 10);

  if (month < 1 || month > 12) return false;

  const daysInMonth = new Date(year, month, 0).getDate();
  return day >= 1 && day <= daysInMonth;
}

/**
 * 校驗並消毒待辦事項欄位
 */
function validateTodoPayload(data, isUpdate = false) {
  const errors = [];
  const sanitized = {};

  // 1. title 校驗
  if (data.title !== undefined || !isUpdate) {
    if (typeof data.title !== 'string' || data.title.trim().length === 0) {
      errors.push('title 必須為非空字串 (長度 1~100 字元)');
    } else if (data.title.trim().length > 100) {
      errors.push('title 長度不可超過 100 字元');
    } else {
      sanitized.title = data.title.trim();
    }
  }

  // 2. dueDate 校驗
  if (data.dueDate !== undefined || !isUpdate) {
    if (!isValidDate(data.dueDate)) {
      errors.push('dueDate 必須為合法之 yyyy-mm-dd 日期格式');
    } else {
      sanitized.dueDate = data.dueDate;
    }
  }

  // 3. state 校驗與預設值
  if (data.state !== undefined) {
    if (!VALID_STATES.includes(data.state)) {
      errors.push(`state 僅限: ${VALID_STATES.join(', ')}`);
    } else {
      sanitized.state = data.state;
    }
  } else if (!isUpdate) {
    sanitized.state = 'todo';
  }

  // 4. category 校驗與預設值
  if (data.category !== undefined) {
    if (!VALID_CATEGORIES.includes(data.category)) {
      errors.push(`category 僅限: ${VALID_CATEGORIES.join(', ')}`);
    } else {
      sanitized.category = data.category;
    }
  } else if (!isUpdate) {
    sanitized.category = 'personal';
  }

  return {
    isValid: errors.length === 0,
    errors,
    sanitized
  };
}

module.exports = {
  validateTodoPayload,
  isValidDate,
  VALID_STATES,
  VALID_CATEGORIES
};
