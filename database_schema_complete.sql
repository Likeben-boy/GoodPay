-- GoodPay 外卖系统完整数据库表结构
-- 集成了用户系统、餐厅管理、订单系统、标签系统等所有模块
-- 优化内容：
-- 1. 所有时间字段改为 DATETIME 类型且非空
-- 2. 为重要数据表增加软删除功能
-- 3. 重新设计订单状态和支付状态
-- 4. 简化支付记录，分离退款逻辑
-- 5. 使用多对多关系管理餐厅标签
-- 6. 添加 DROP TABLE IF EXISTS 确保表重建
-- 7. 将所有 TINYINT(1) 改为 BOOL 类型
-- 8. 按依赖关系正确排序表创建顺序
-- 9. 移除所有外键约束，确保表可以自由删除

-- ========================================
-- 基础数据表（无外键依赖）
-- ========================================

-- 用户表 (users) - 基础用户信息
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    phone VARCHAR(20) NOT NULL UNIQUE COMMENT '手机号',
    password VARCHAR(255) NOT NULL COMMENT '密码(加密)',
    avatar VARCHAR(255) COMMENT '头像URL',
    nickname VARCHAR(50) COMMENT '昵称',
    status BOOL NOT NULL DEFAULT TRUE COMMENT '状态：TRUE-正常，FALSE-禁用',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at DATETIME NULL COMMENT '删除时间（软删除）',
    INDEX idx_phone (phone),
    INDEX idx_username (username),
    INDEX idx_status (status),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 餐厅表 (restaurants)
DROP TABLE IF EXISTS restaurants;
CREATE TABLE restaurants (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '餐厅ID',
    name VARCHAR(100) NOT NULL COMMENT '餐厅名称',
    image VARCHAR(255) NOT NULL COMMENT '餐厅图片URL',
    rating DECIMAL(2,1) NOT NULL DEFAULT 0.0 COMMENT '餐厅评分',
    distance DECIMAL(4,2) NOT NULL DEFAULT 0.0 COMMENT '距离(公里)',
    delivery_fee DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT '配送费(元)',
    delivery_time INT NOT NULL DEFAULT 0 COMMENT '配送时间(分钟)',
    status BOOL NOT NULL DEFAULT TRUE COMMENT '状态：TRUE-营业中，FALSE-休息中',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at DATETIME NULL COMMENT '删除时间（软删除）',
    INDEX idx_rating (rating),
    INDEX idx_distance (distance),
    INDEX idx_status (status),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='餐厅信息表';

-- 餐厅标签主表 (restaurant_tag_master)
DROP TABLE IF EXISTS restaurant_tag_master;
CREATE TABLE restaurant_tag_master (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '标签ID',
    tag_name VARCHAR(50) NOT NULL UNIQUE COMMENT '标签名称',
    tag_type ENUM('cuisine', 'feature', 'price_range', 'service') DEFAULT 'cuisine' COMMENT '标签类型：cuisine-菜系, feature-特色, price_range-价格区间, service-服务',
    color VARCHAR(7) DEFAULT '#ff6b6b' COMMENT '标签颜色(十六进制)',
    icon VARCHAR(100) COMMENT '标签图标',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序顺序',
    status BOOL NOT NULL DEFAULT TRUE COMMENT '状态：TRUE-启用，FALSE-禁用',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_tag_type (tag_type),
    INDEX idx_sort_order (sort_order),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='餐厅标签主表';

-- 优惠券表 (coupons) - 移到前面，因为其他表可能依赖它
DROP TABLE IF EXISTS coupons;
CREATE TABLE coupons (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '优惠券ID',
    coupon_name VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    coupon_type ENUM('discount', 'full_reduce') NOT NULL COMMENT '优惠券类型：discount-折扣，full_reduce-满减',
    discount_value DECIMAL(10,2) NOT NULL COMMENT '优惠金额/折扣值',
    min_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT '最低消费金额',
    max_discount DECIMAL(10,2) COMMENT '最大优惠金额(折扣券专用)',
    total_count INT NOT NULL DEFAULT 0 COMMENT '发放总数',
    used_count INT NOT NULL DEFAULT 0 COMMENT '已使用数量',
    valid_from DATETIME NOT NULL COMMENT '有效期开始时间',
    valid_until DATETIME NOT NULL COMMENT '有效期结束时间',
    status ENUM('active', 'inactive', 'expired') NOT NULL DEFAULT 'active' COMMENT '状态',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at DATETIME NULL COMMENT '删除时间（软删除）',
    INDEX idx_coupon_type (coupon_type),
    INDEX idx_status (status),
    INDEX idx_valid_period (valid_from, valid_until),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='优惠券表';

-- ========================================
-- 二级数据表（依赖基础表）
-- ========================================

-- 用户地址表 (user_addresses)
DROP TABLE IF EXISTS user_addresses;
CREATE TABLE user_addresses (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '地址ID',
    user_id INT NOT NULL COMMENT '用户ID',
    contact_name VARCHAR(50) NOT NULL COMMENT '联系人姓名',
    contact_phone VARCHAR(20) NOT NULL COMMENT '联系人电话',
    province VARCHAR(50) NOT NULL COMMENT '省份',
    city VARCHAR(50) NOT NULL COMMENT '城市',
    district VARCHAR(50) NOT NULL COMMENT '区县',
    detail_address VARCHAR(255) NOT NULL COMMENT '详细地址',
    is_default BOOL NOT NULL DEFAULT FALSE COMMENT '是否默认地址：TRUE-是，FALSE-否',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_is_default (is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户地址表';

-- 菜品分类表 (dish_categories)
DROP TABLE IF EXISTS dish_categories;
CREATE TABLE dish_categories (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    restaurant_id INT NOT NULL COMMENT '餐厅ID',
    name VARCHAR(50) NOT NULL COMMENT '分类名称',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序顺序',
    status BOOL NOT NULL DEFAULT TRUE COMMENT '状态：TRUE-启用，FALSE-禁用',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_restaurant_id (restaurant_id),
    INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品分类表';

-- 餐厅标签关联表 (restaurant_tag_relations)
DROP TABLE IF EXISTS restaurant_tag_relations;
CREATE TABLE restaurant_tag_relations (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '关联ID',
    restaurant_id INT NOT NULL COMMENT '餐厅ID',
    tag_id INT NOT NULL COMMENT '标签ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    created_by INT COMMENT '创建者ID(系统管理员或商家)',
    UNIQUE KEY uk_restaurant_tag (restaurant_id, tag_id),
    INDEX idx_restaurant_id (restaurant_id),
    INDEX idx_tag_id (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='餐厅标签关联表';

-- ========================================
-- 三级数据表（依赖二级表）
-- ========================================

-- 菜品表 (dishes)
DROP TABLE IF EXISTS dishes;
CREATE TABLE dishes (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '菜品ID',
    restaurant_id INT NOT NULL COMMENT '餐厅ID',
    category_id INT NOT NULL COMMENT '分类ID',
    name VARCHAR(100) NOT NULL COMMENT '菜品名称',
    description TEXT COMMENT '菜品描述',
    price DECIMAL(8,2) NOT NULL DEFAULT 0.00 COMMENT '价格(元)',
    image VARCHAR(255) COMMENT '菜品图片URL',
    status BOOL NOT NULL DEFAULT TRUE COMMENT '状态：TRUE-上架，FALSE-下架',
    sales_count INT NOT NULL DEFAULT 0 COMMENT '销售数量',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at DATETIME NULL COMMENT '删除时间（软删除）',
    INDEX idx_restaurant_id (restaurant_id),
    INDEX idx_category_id (category_id),
    INDEX idx_price (price),
    INDEX idx_sales_count (sales_count),
    INDEX idx_status (status),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品表';

-- 用户优惠券表 (user_coupons)
DROP TABLE IF EXISTS user_coupons;
CREATE TABLE user_coupons (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户优惠券ID',
    user_id INT NOT NULL COMMENT '用户ID',
    coupon_id INT NOT NULL COMMENT '优惠券ID',
    order_id INT COMMENT '使用的订单ID',
    status ENUM('unused', 'used', 'expired') NOT NULL DEFAULT 'unused' COMMENT '状态',
    received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
    used_at DATETIME NULL COMMENT '使用时间',
    expired_at DATETIME NOT NULL COMMENT '过期时间',
    INDEX idx_user_id (user_id),
    INDEX idx_coupon_id (coupon_id),
    INDEX idx_status (status),
    INDEX idx_expired_at (expired_at),
    UNIQUE KEY uk_user_coupon (user_id, coupon_id, received_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户优惠券表';

-- 餐厅标签使用统计表 (restaurant_tag_stats)
DROP TABLE IF EXISTS restaurant_tag_stats;
CREATE TABLE restaurant_tag_stats (
    tag_id INT PRIMARY KEY COMMENT '标签ID',
    usage_count INT NOT NULL DEFAULT 0 COMMENT '使用次数',
    last_used_at DATETIME NULL COMMENT '最后使用时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='餐厅标签使用统计表';

-- ========================================
-- 业务数据表（订单相关）
-- ========================================

-- 订单表 (orders)
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    order_number VARCHAR(32) NOT NULL UNIQUE COMMENT '订单号',
    user_id INT NOT NULL COMMENT '用户ID',
    restaurant_id INT NOT NULL COMMENT '餐厅ID',
    address_id INT NOT NULL COMMENT '收货地址ID',
    contact_name VARCHAR(50) NOT NULL COMMENT '联系人姓名',
    contact_phone VARCHAR(20) NOT NULL COMMENT '联系人电话',
    delivery_address VARCHAR(255) NOT NULL COMMENT '配送地址',

    -- 订单状态（业务流程状态）
    order_status ENUM('created', 'confirmed', 'preparing', 'delivering', 'completed', 'cancelled') NOT NULL DEFAULT 'created' COMMENT '订单状态：created-订单创建, confirmed-商家确认, preparing-准备中, delivering-配送中, completed-已完成, cancelled-已取消',

    -- 支付状态（资金流状态）
    payment_status ENUM('pending', 'processing', 'success', 'failed', 'refunding', 'refunded') NOT NULL DEFAULT 'pending' COMMENT '支付状态：pending-待支付, processing-支付处理中, success-支付成功, failed-支付失败, refunding-退款中, refunded-已退款',

    payment_method ENUM('wechat', 'alipay', 'balance', 'apple') COMMENT '支付方式',
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '商品小计',
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '配送费',
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '订单总额',
    coupon_id INT COMMENT '使用的优惠券ID',
    order_note TEXT COMMENT '订单备注',
    delivery_time VARCHAR(100) COMMENT '配送时间',
    estimated_delivery_time DATETIME NULL COMMENT '预计送达时间',
    actual_delivery_time DATETIME NULL COMMENT '实际送达时间',

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    paid_at DATETIME NULL COMMENT '支付时间',
    completed_at DATETIME NULL COMMENT '完成时间',
    cancelled_at DATETIME NULL COMMENT '取消时间',
    cancel_reason VARCHAR(255) COMMENT '取消原因',
    deleted_at DATETIME NULL COMMENT '删除时间（软删除）',

    INDEX idx_user_id (user_id),
    INDEX idx_restaurant_id (restaurant_id),
    INDEX idx_order_status (order_status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_created_at (created_at),
    INDEX idx_order_number (order_number),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- 订单商品表 (order_items)
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '订单商品ID',
    order_id INT NOT NULL COMMENT '订单ID',
    dish_id INT NOT NULL COMMENT '菜品ID',
    dish_name VARCHAR(100) NOT NULL COMMENT '菜品名称(快照)',
    dish_image VARCHAR(255) COMMENT '菜品图片(快照)',
    dish_price DECIMAL(8,2) NOT NULL COMMENT '菜品单价(快照)',
    quantity INT NOT NULL DEFAULT 1 COMMENT '购买数量',
    selected_spec VARCHAR(100) COMMENT '选择的规格',
    subtotal DECIMAL(10,2) NOT NULL COMMENT '小计金额',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    INDEX idx_order_id (order_id),
    INDEX idx_dish_id (dish_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单商品表';

-- 购物车表 (shopping_cart)
DROP TABLE IF EXISTS shopping_cart;
CREATE TABLE shopping_cart (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '购物车ID',
    user_id INT NOT NULL COMMENT '用户ID',
    restaurant_id INT NOT NULL COMMENT '餐厅ID',
    dish_id INT NOT NULL COMMENT '菜品ID',
    quantity INT NOT NULL DEFAULT 1 COMMENT '数量',
    price DECIMAL(8,2) NOT NULL COMMENT '单价(快照价格)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_user_restaurant_dish (user_id, restaurant_id, dish_id),
    INDEX idx_user_id (user_id),
    INDEX idx_restaurant_id (restaurant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车表';

-- 支付记录表 (payment_records) - 简化版，只关注支付流程
DROP TABLE IF EXISTS payment_records;
CREATE TABLE payment_records (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '支付记录ID',
    order_id INT NOT NULL COMMENT '订单ID',
    user_id INT NOT NULL COMMENT '用户ID',
    payment_method ENUM('wechat', 'alipay', 'balance', 'apple') NOT NULL COMMENT '支付方式',
    payment_amount DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    transaction_id VARCHAR(100) COMMENT '第三方交易号',
    payment_status ENUM('pending', 'processing', 'success', 'failed') NOT NULL DEFAULT 'pending' COMMENT '支付状态',
    payment_time DATETIME NULL COMMENT '支付成功时间',
    failure_reason VARCHAR(255) COMMENT '支付失败原因',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    INDEX idx_order_id (order_id),
    INDEX idx_user_id (user_id),
    INDEX idx_payment_status (payment_status),
    INDEX idx_transaction_id (transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付记录表';

-- 退款记录表 (refund_records) - 简化版，支持单次退款
DROP TABLE IF EXISTS refund_records;
CREATE TABLE refund_records (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '退款记录ID',
    order_id INT NOT NULL COMMENT '订单ID',
    user_id INT NOT NULL COMMENT '用户ID',
    payment_record_id INT NOT NULL COMMENT '原支付记录ID',
    refund_amount DECIMAL(10,2) NOT NULL COMMENT '退款金额',
    refund_reason VARCHAR(255) NOT NULL COMMENT '退款原因',
    refund_type ENUM('full', 'partial') NOT NULL DEFAULT 'full' COMMENT '退款类型：full-全额退款，partial-部分退款',
    refund_status ENUM('pending', 'approved', 'rejected', 'completed', 'failed') NOT NULL DEFAULT 'pending' COMMENT '退款状态',
    refund_method ENUM('original', 'balance') DEFAULT 'original' COMMENT '退款方式：original-原路退回，balance-退到余额',
    refund_transaction_id VARCHAR(100) COMMENT '退款交易号',
    processor_id INT COMMENT '处理人ID',
    processor_type ENUM('user', 'merchant', 'system') DEFAULT 'system' COMMENT '处理人类型',
    process_remark VARCHAR(255) COMMENT '处理备注',
    processed_at DATETIME NULL COMMENT '处理时间',
    completed_at DATETIME NULL COMMENT '完成时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    INDEX idx_order_id (order_id),
    INDEX idx_user_id (user_id),
    INDEX idx_refund_status (refund_status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款记录表';

-- 订单状态日志表 (order_status_logs)
DROP TABLE IF EXISTS order_status_logs;
CREATE TABLE order_status_logs (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    order_id INT NOT NULL COMMENT '订单ID',
    old_status VARCHAR(20) COMMENT '原状态',
    new_status VARCHAR(20) NOT NULL COMMENT '新状态',
    operator_id INT COMMENT '操作人ID',
    operator_type ENUM('user', 'merchant', 'delivery', 'system') DEFAULT 'system' COMMENT '操作人类型',
    remark VARCHAR(255) COMMENT '备注',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    INDEX idx_order_id (order_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单状态日志表';

-- 订单评价表 (order_reviews)
DROP TABLE IF EXISTS order_reviews;
CREATE TABLE order_reviews (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '评价ID',
    order_id INT NOT NULL COMMENT '订单ID',
    user_id INT NOT NULL COMMENT '用户ID',
    restaurant_id INT NOT NULL COMMENT '餐厅ID',
    rating TINYINT NOT NULL COMMENT '评分(1-5)',
    content TEXT COMMENT '评价内容',
    images JSON COMMENT '评价图片',
    reply_content TEXT COMMENT '商家回复',
    reply_time DATETIME NULL COMMENT '回复时间',
    status ENUM('published', 'hidden', 'deleted') NOT NULL DEFAULT 'published' COMMENT '状态',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at DATETIME NULL COMMENT '删除时间（软删除）',

    UNIQUE KEY uk_order_id (order_id),
    INDEX idx_restaurant_id (restaurant_id),
    INDEX idx_rating (rating),
    INDEX idx_status (status),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单评价表';

-- 配送信息表 (delivery_info)
DROP TABLE IF EXISTS delivery_info;
CREATE TABLE delivery_info (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '配送ID',
    order_id INT NOT NULL COMMENT '订单ID',
    delivery_user_id INT COMMENT '配送员ID',
    delivery_status ENUM('assigned', 'picked_up', 'delivering', 'delivered') NOT NULL DEFAULT 'assigned' COMMENT '配送状态',
    assigned_at DATETIME NULL COMMENT '分配时间',
    picked_up_at DATETIME NULL COMMENT '取餐时间',
    delivered_at DATETIME NULL COMMENT '送达时间',
    delivery_distance DECIMAL(8,2) COMMENT '配送距离(公里)',
    delivery_duration INT COMMENT '配送时长(分钟)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    UNIQUE KEY uk_order_id (order_id),
    INDEX idx_delivery_user_id (delivery_user_id),
    INDEX idx_delivery_status (delivery_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配送信息表';

-- ========================================
-- 示例数据插入
-- ========================================

-- 插入餐厅示例数据
INSERT INTO restaurants (id, name, image, rating, distance, delivery_fee, delivery_time) VALUES
(1, '川味小厨', '/images/restaurant1.jpg', 4.8, 1.2, 5.00, 30),
(2, '粤式茶餐厅', '/images/restaurant2.jpg', 4.6, 2.1, 6.00, 35),
(3, '日式料理店', '/images/restaurant3.jpg', 4.9, 0.8, 8.00, 25);

-- 插入餐厅标签数据
INSERT INTO restaurant_tag_master (tag_name, tag_type, color, sort_order) VALUES
-- 菜系类标签
('川菜', 'cuisine', '#ff6b6b', 1),
('粤菜', 'cuisine', '#ff6b6b', 2),
('湘菜', 'cuisine', '#ff6b6b', 3),
('鲁菜', 'cuisine', '#ff6b6b', 4),
('火锅', 'cuisine', '#ff6b6b', 5),
('烧烤', 'cuisine', '#ff6b6b', 6),
('日料', 'cuisine', '#ff6b6b', 7),
('西餐', 'cuisine', '#ff6b6b', 8),
('快餐', 'cuisine', '#ff6b6b', 9),
('东北菜', 'cuisine', '#ff6b6b', 10),

-- 特色类标签
('麻辣', 'feature', '#52c41a', 1),
('清淡', 'feature', '#52c41a', 2),
('香辣', 'feature', '#52c41a', 3),
('酸甜', 'feature', '#52c41a', 4),
('素食', 'feature', '#52c41a', 5),
('海鲜', 'feature', '#52c41a', 6),
('牛肉', 'feature', '#52c41a', 7),
('鸡肉', 'feature', '#52c41a', 8),
('猪肉', 'feature', '#52c41a', 9),

-- 价格区间标签
('经济实惠', 'price_range', '#1890ff', 1),
('中等消费', 'price_range', '#1890ff', 2),
('高档餐厅', 'price_range', '#1890ff', 3),

-- 服务类标签
('24小时营业', 'service', '#faad14', 1),
('外卖专送', 'service', '#faad14', 2),
('到店自取', 'service', '#faad14', 3),
('包厢预定', 'service', '#faad14', 4),
('免费WiFi', 'service', '#faad14', 5),
('停车场', 'service', '#faad14', 6);

-- 插入餐厅标签关联数据
INSERT INTO restaurant_tag_relations (restaurant_id, tag_id) VALUES
(1, 1),  -- 川味小厨 - 川菜
(1, 11), -- 川味小厨 - 麻辣
(1, 17), -- 川味小厨 - 经济实惠
(2, 2),  -- 粤式茶餐厅 - 粤菜
(2, 12), -- 粤式茶餐厅 - 清淡
(2, 18), -- 粤式茶餐厅 - 中等消费
(3, 7),  -- 日式料理店 - 日料
(3, 19), -- 日式料理店 - 高档餐厅
(3, 22); -- 日式料理店 - 包厢预定

-- 插入菜品分类数据
INSERT INTO dish_categories (id, restaurant_id, name, sort_order) VALUES
(1, 1, '热销菜品', 1),
(2, 1, '汤品', 2),
(3, 1, '主食', 3),
(4, 2, '招牌茶点', 1),
(5, 2, '粤式小炒', 2),
(6, 2, '汤品粥品', 3),
(7, 3, '刺身寿司', 1),
(8, 3, '烤物炸物', 2),
(9, 3, '拉面主食', 3);

-- 插入菜品数据
INSERT INTO dishes (id, restaurant_id, category_id, name, description, price, image) VALUES
-- 川味小厨菜品
(1, 1, 1, '麻婆豆腐', '经典川菜，麻辣鲜香', 18.00, '/images/dish1.jpg'),
(2, 1, 1, '宫保鸡丁', '鸡肉鲜嫩，花生香脆', 22.00, '/images/dish2.jpg'),
(3, 1, 2, '番茄鸡蛋汤', '酸甜开胃，营养丰富', 18.00, '/images/dish3.jpg'),
(4, 1, 3, '蛋炒饭', '粒粒分明，香气扑鼻', 15.00, '/images/dish4.jpg'),
(5, 1, 1, '水煮鱼', '麻辣鲜香，鱼肉嫩滑', 38.00, '/images/dish5.jpg'),

-- 粤式茶餐厅菜品
(6, 2, 4, '虾饺', '晶莹剔透，鲜虾饱满', 28.00, '/images/dish6.jpg'),
(7, 2, 4, '叉烧包', '松软香甜，叉烧入味', 18.00, '/images/dish7.jpg'),
(8, 2, 5, '白切鸡', '皮脆肉嫩，原汁原味', 45.00, '/images/dish8.jpg'),
(9, 2, 6, '皮蛋瘦肉粥', '绵密顺滑，营养丰富', 16.00, '/images/dish9.jpg'),

-- 日式料理店菜品
(10, 3, 7, '三文鱼刺身', '新鲜三文鱼，口感鲜美', 68.00, '/images/dish10.jpg'),
(11, 3, 7, '金枪鱼寿司', '优质金枪鱼，传统工艺', 38.00, '/images/dish11.jpg'),
(12, 3, 8, '天妇罗', '酥脆可口，海鲜蔬菜', 35.00, '/images/dish12.jpg'),
(13, 3, 9, '豚骨拉面', '浓郁汤底，面条劲道', 42.00, '/images/dish13.jpg');

-- 插入优惠券数据
INSERT INTO coupons (id, coupon_name, coupon_type, discount_value, min_amount, valid_from, valid_until) VALUES
(1, '新用户立减5元', 'full_reduce', 5.00, 20.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59'),
(2, '满30减8元', 'full_reduce', 8.00, 30.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59'),
(3, '9折优惠券', 'discount', 0.90, 0.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59'),
(4, '满50减15元', 'full_reduce', 15.00, 50.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59'),
(5, '8.5折优惠券', 'discount', 0.85, 0.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59');

-- 插入用户示例数据
INSERT INTO users (id, username, phone, password, nickname) VALUES
(1, 'user001', '13812345678', 'hashed_password_001', '美食达人'),
(2, 'user002', '13987654321', 'hashed_password_002', '小吃货'),
(3, 'delivery01', '13611111111', 'hashed_password_delivery', '配送员小王');

-- 插入用户地址数据
INSERT INTO user_addresses (user_id, contact_name, contact_phone, province, city, district, detail_address, is_default) VALUES
(1, '张三', '13812345678', '北京市', '北京市', '朝阳区', '三里屯街道工体北路8号院1号楼', TRUE),
(1, '张三', '13812345678', '北京市', '北京市', '海淀区', '中关村大街27号中关村大厦', FALSE),
(2, '李四', '13987654321', '上海市', '上海市', '浦东新区', '陆家嘴环路1000号', TRUE);

-- 插入用户优惠券数据
INSERT INTO user_coupons (user_id, coupon_id, expired_at) VALUES
(1, 1, '2024-12-31 23:59:59'),
(1, 2, '2024-12-31 23:59:59'),
(1, 3, '2024-12-31 23:59:59'),
(2, 1, '2024-12-31 23:59:59'),
(2, 4, '2024-12-31 23:59:59');

-- 插入订单示例数据
INSERT INTO orders (
    order_number, user_id, restaurant_id, address_id, contact_name, contact_phone,
    delivery_address, order_status, payment_status, payment_method, subtotal,
    delivery_fee, discount_amount, total_amount, coupon_id, order_note
) VALUES
('GP2024011500123', 1, 1, 1, '张三', '138****5678', '北京市朝阳区三里屯街道工体北路8号院1号楼', 'confirmed', 'success', 'wechat', 40.00, 5.00, 2.00, 43.00, 1, '不要太辣'),
('GP2024011500124', 2, 2, 3, '李四', '139****4321', '上海市浦东新区陆家嘴环路1000号', 'confirmed', 'success', 'alipay', 63.00, 6.00, 0.00, 69.00, NULL, '打包送到前台');

-- 插入订单商品数据
INSERT INTO order_items (order_id, dish_id, dish_name, dish_image, dish_price, quantity, subtotal) VALUES
(1, 1, '麻婆豆腐', '/images/dish1.jpg', 18.00, 1, 18.00),
(1, 2, '宫保鸡丁', '/images/dish2.jpg', 22.00, 1, 22.00),
(2, 6, '虾饺', '/images/dish6.jpg', 28.00, 1, 28.00),
(2, 7, '叉烧包', '/images/dish7.jpg', 18.00, 1, 18.00),
(2, 8, '白切鸡', '/images/dish8.jpg', 45.00, 1, 45.00);

-- 插入支付记录数据
INSERT INTO payment_records (order_id, user_id, payment_method, payment_amount, transaction_id, payment_status, payment_time) VALUES
(1, 1, 'wechat', 43.00, 'wx1234567890', 'success', '2024-01-15 12:30:00'),
(2, 2, 'alipay', 69.00, 'ali9876543210', 'success', '2024-01-15 13:15:00');

-- 插入订单状态日志数据
INSERT INTO order_status_logs (order_id, old_status, new_status, operator_type, remark) VALUES
(1, NULL, 'created', 'user', '用户下单'),
(1, 'created', 'confirmed', 'merchant', '商家确认订单'),
(2, NULL, 'created', 'user', '用户下单'),
(2, 'created', 'confirmed', 'merchant', '商家确认订单');

-- 插入标签使用统计数据
INSERT INTO restaurant_tag_stats (tag_id, usage_count, last_used_at) VALUES
(1, 1, NOW()),   -- 川菜使用1次
(11, 1, NOW()),  -- 麻辣使用1次
(17, 1, NOW()),  -- 经济实惠使用1次
(2, 1, NOW()),   -- 粤菜使用1次
(12, 1, NOW()),  -- 清淡使用1次
(18, 1, NOW());  -- 中等消费使用1次

-- ========================================
-- 常用查询示例
-- ========================================

-- 1. 查询用户订单列表
SELECT
    o.id,
    o.order_number,
    o.order_status,
    o.payment_status,
    o.total_amount,
    o.created_at,
    r.name as restaurant_name,
    r.image as restaurant_image
FROM orders o
LEFT JOIN restaurants r ON o.restaurant_id = r.id
WHERE o.user_id = 1 AND o.deleted_at IS NULL
ORDER BY o.created_at DESC;

-- 2. 查询订单详情
SELECT
    o.*,
    r.name as restaurant_name,
    r.image as restaurant_image,
    a.contact_name,
    a.contact_phone,
    CONCAT(a.province, a.city, a.district, a.detail_address) as full_address
FROM orders o
LEFT JOIN restaurants r ON o.restaurant_id = r.id
LEFT JOIN user_addresses a ON o.address_id = a.id
WHERE o.id = 1 AND o.deleted_at IS NULL;

-- 3. 查询订单商品明细
SELECT
    oi.*,
    d.description as dish_description
FROM order_items oi
LEFT JOIN dishes d ON oi.dish_id = d.id
WHERE oi.order_id = 1;

-- 4. 查询餐厅及其标签
SELECT
    r.id,
    r.name,
    r.rating,
    r.distance,
    r.delivery_fee,
    GROUP_CONCAT(
        CONCAT(tm.tag_name, '(', tm.tag_type, ')')
        ORDER BY tm.sort_order
        SEPARATOR ', '
    ) as tags
FROM restaurants r
LEFT JOIN restaurant_tag_relations rtr ON r.id = rtr.restaurant_id
LEFT JOIN restaurant_tag_master tm ON rtr.tag_id = tm.id
WHERE r.deleted_at IS NULL AND tm.status = TRUE
GROUP BY r.id, r.name, r.rating, r.distance, r.delivery_fee
ORDER BY r.rating DESC;

-- 5. 查询用户优惠券
SELECT
    uc.id,
    c.coupon_name,
    c.coupon_type,
    c.discount_value,
    c.min_amount,
    uc.status,
    uc.expired_at,
    CASE
        WHEN uc.status = 'unused' AND uc.expired_at > NOW() THEN '可用'
        WHEN uc.status = 'used' THEN '已使用'
        WHEN uc.status = 'expired' OR uc.expired_at <= NOW() THEN '已过期'
        ELSE '不可用'
    END as availability
FROM user_coupons uc
LEFT JOIN coupons c ON uc.coupon_id = c.id
WHERE uc.user_id = 1 AND c.deleted_at IS NULL
ORDER BY uc.expired_at ASC;

-- 6. 查询餐厅菜品
SELECT
    d.id,
    d.name,
    d.description,
    d.price,
    d.image,
    d.sales_count,
    dc.name as category_name
FROM dishes d
LEFT JOIN dish_categories dc ON d.category_id = dc.id
WHERE d.restaurant_id = 1 AND d.deleted_at IS NULL AND d.status = TRUE
ORDER BY dc.sort_order, d.sales_count DESC;

-- 7. 退款流程示例
-- 1. 创建退款申请
INSERT INTO refund_records (
    order_id, user_id, payment_record_id, refund_amount, refund_reason,
    refund_type, refund_status, refund_method
) VALUES (
    1, 1, 1, 43.00, '用户主动取消订单', 'full', 'pending', 'original'
);

-- 2. 处理退款申请（批准）
UPDATE refund_records
SET refund_status = 'approved',
    processor_id = 2,
    processor_type = 'merchant',
    processed_at = NOW(),
    process_remark = '商家同意退款'
WHERE id = 1;

-- 3. 完成退款
UPDATE refund_records
SET refund_status = 'completed',
    refund_transaction_id = 'rf1234567890',
    completed_at = NOW()
WHERE id = 1;

-- 4. 更新订单支付状态
UPDATE orders
SET payment_status = 'refunding'
WHERE id = 1;

UPDATE orders
SET payment_status = 'refunded'
WHERE id = 1;

-- 5. 更新优惠券使用状态
UPDATE user_coupons
SET status = 'unused',
    order_id = NULL,
    used_at = NULL
WHERE order_id = 1;

-- ========================================
-- 软删除使用示例
-- ========================================

-- 软删除餐厅（标记为已删除）
UPDATE restaurants
SET deleted_at = NOW()
WHERE id = 1;

-- 查询未删除的餐厅
SELECT * FROM restaurants WHERE deleted_at IS NULL;

-- 恢复软删除的餐厅
UPDATE restaurants
SET deleted_at = NULL
WHERE id = 1;

-- 永久删除软删除的数据（谨慎使用）
DELETE FROM restaurants WHERE deleted_at IS NOT NULL AND deleted_at < DATE_SUB(NOW(), INTERVAL 30 DAY);